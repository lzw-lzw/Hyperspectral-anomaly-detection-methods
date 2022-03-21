/**
 * mex -largeArrayDims hybridseg.cpp
 */

#include<mex.h>
#include <stdio.h>
#include <math.h>
#include <float.h>

// 定义几种不同的光谱相似性测度方式

//1. 欧式距离
// 输入：以向量形式表示的高光谱像元，向量长度为bands
double calEuclidean(double* v1, double* v2, int bands)
{
    int i;
    double dist = 0.0;
    for(i=0; i<bands; i++)
    {
        dist += (v1[i]-v2[i])*(v1[i]-v2[i]);
    }
    return sqrt(dist);
}

//2. SAD 光谱角距离，范围 [0---PI]弧度
double calSAD(double* v1, double* v2, int bands)
{
    int i;
    double nor_v1, nor_v2, inner, theta;
    nor_v1 = nor_v2 = 0;
    inner = 0;
    for(i=0; i<bands; i++)
    {
        nor_v1 += v1[i]*v1[i];
        nor_v2 += v2[i]*v2[i];
        inner += v1[i]*v2[i];
    }
    inner = inner/(sqrt(nor_v1)*sqrt(nor_v2));
    theta = acos(inner);
    
    return theta; //弧度
}

//3. SID spectral information diffusion 光谱信息散度 ，范围大概[0---1]
double calSID(double* v1, double* v2, int bands)
{
    int i;
    double sum_v1, sum_v2;
    double* p1, *p2;
    double sid;
    
    p1 = (double*)mxMalloc(sizeof(double) * bands);
    p2 = (double*)mxMalloc(sizeof(double) * bands);
    
    sum_v1 = sum_v2 = 0;
    for(i=0; i<bands; i++)
    {
        sum_v1 += v1[i];
        sum_v2 += v2[i];
    }
    
    for(i=0; i<bands; i++)
    {
        p1[i] = v1[i]/sum_v1;
        p2[i] = v2[i]/sum_v2;
    }
    
    sid = 0;
    for(i=0; i<bands; i++)
    {
        sid += (p1[i]-p2[i])*log(p1[i]/p2[i]); 
    }
       
    mxFree(p1);
    mxFree(p2);
    
    return sid;
}

//4. SID * tan(SAD) 联合SID和SAD
double cal_SAD_SID(double* v1, double* v2, int bands)
{
    double sad, sid;
    sad = calSAD(v1, v2, bands);
    sid = calSID(v1, v2, bands);
	return sid*tan(sad);  // 修改日期 2016-10-16 公式修改
    //return sad*tan(sid);
}

////////////////////////////////////////////////////////////////////////////////////

/*
得到初始聚类的种子（索引）以及种子的数目
seedIndices：大小为numseeds,存放每个种子的索引值
*/
void getSeeds(int STEP, int width, int height, int* seedIndices, int* numseeds)
{
    const bool hexgrid = false;
	int n;
    int xstrips, ystrips;
    int xerr, yerr;
    double xerrperstrip,yerrperstrip;
    int xoff,yoff;
    int x,y;
    int xe,ye;
    int seedx,seedy;
    int i;

	xstrips = (int)(0.5+(double)(width)/(double)(STEP));
	ystrips = (int)(0.5+(double)(height)/(double)(STEP));
    
    xerr = width  - STEP*xstrips;if(xerr < 0){xstrips--;xerr = width - STEP*xstrips;}//多余的未处理的像元
    yerr = height - STEP*ystrips;if(yerr < 0){ystrips--;yerr = height- STEP*ystrips;}
    
	xerrperstrip = (double)(xerr)/(double)(xstrips); //分配给每一个strip的误差
	yerrperstrip = (double)(yerr)/(double)(ystrips);
    
	xoff = STEP/2;
	yoff = STEP/2;
    
    n = 0;
	for( y = 0; y < ystrips; y++ )
	{
		ye = y*yerrperstrip;
		for( x = 0; x < xstrips; x++ )
		{
			xe = x*xerrperstrip;
            seedx = (x*STEP+xoff+xe);
            if(hexgrid){ seedx = x*STEP+(xoff<<(y&0x1))+xe; if(seedx >= width)seedx = width-1; }//for hex grid sampling
            seedy = (y*STEP+yoff+ye);
            i = seedy*width + seedx;
			seedIndices[n] = i;
			n++;
		}
	}
    *numseeds = n;
}


/*当SLIC用于高光谱数据时，传统的5D数据需要扩展成(bands+2)维数据，bands表示光谱维的波段数*/
void PerformSuperpixelSLIC(
						   double* spectral_vec, double* kseeds, int bands, //光谱域数据						   
						   double* kseedsx, double* kseedsy,                  //空间域数据
						   int width, int height, 
						   int numseeds, int* klabels, int STEP, double compactness, int dist_type)
{
    int x1, y1, x2, y2; //定义聚类搜索边界，即2*Step大小的搜索空间
	
	double dist;
	double distxy;
    int itr; // 迭代数，default=10
    int n, x, y;
    int i;
    int ind;
    int r,c;
    int k;
    int b;
    
    int sz = width*height;     //sz表示像元总数
	const int numk = numseeds; //numk表示种子数
	int offset = STEP;         //offset表示分割块边长
    
    
    double* distvec = (double*)mxMalloc(sizeof(double) * sz);
// 	double invwt = 1.0/((STEP/compactness)*(STEP/compactness));
    double invwt = compactness/STEP;

	double* clustersize = (double*)mxMalloc(sizeof(double) * numk);
    double* inv         = (double*)mxMalloc(sizeof(double) * numk);

    double* sigmabs     = (double*)mxMalloc(sizeof(double) * numk * bands);
    double* sigmax      = (double*)mxMalloc(sizeof(double) * numk);
    double* sigmay      = (double*)mxMalloc(sizeof(double) * numk);
    
	for( itr = 0; itr < 10; itr++ )  //迭代10次
	{
		for(i = 0; i < sz; i++){distvec[i] = DBL_MAX;}
     
		for( n = 0; n < numk; n++ ) //对每个超像元做搜索
		{
            //2 * STEP 大小的搜索空间
            x1 = kseedsx[n]-offset; if(x1 < 0) x1 = 0;
            y1 = kseedsy[n]-offset; if(y1 < 0) y1 = 0;
            x2 = kseedsx[n]+offset; if(x2 > width)  x2 = width;
            y2 = kseedsy[n]+offset; if(y2 > height) y2 = height;
            
			//仅在2*Step大小的搜索空间进行距离测度
			for( y = y1; y < y2; y++ )
			{
				for( x = x1; x < x2; x++ )
				{
					i = y * width + x; //待检测像素点
                    
                    //计算光谱距离
                    // spectral_vec[i*bands]----spectral_vec[(i+1)*bands-1] 邻域像元的光谱向量
                    // kseeds[n*bands]----kseeds[(n+1)*bands-1] 表示聚类种子像元的光谱向量
                    switch(dist_type)
                    {
                        case 1:   //欧式距离
                            dist = calEuclidean(&spectral_vec[i*bands], &kseeds[n*bands], bands);
                            break;
                        case 2:   //SAD
                            dist = calSAD(&spectral_vec[i*bands], &kseeds[n*bands], bands);
                            break;
                        case 3:   //SID
                            dist = calSID(&spectral_vec[i*bands], &kseeds[n*bands], bands);
                            break;
                        case 4:   // SAD-SID
                            dist = cal_SAD_SID(&spectral_vec[i*bands], &kseeds[n*bands], bands);
                            break;
                    }
                    
                    // 计算空间距离
					distxy = sqrt((x - kseedsx[n])*(x - kseedsx[n]) + (y - kseedsy[n])*(y - kseedsy[n]));
                    
					dist = dist*(1-compactness) + distxy*invwt;  //SLIC距离公式
                    
					if(dist < distvec[i])
					{
						distvec[i] = dist;
						klabels[i] = n; //属于第 n 号聚类
					}
				}
			}
		}

		//-----------------------------------------------------------------
		// Recalculate the centroid and store in the seed values
		//-----------------------------------------------------------------
		
        //重新初始化聚类中心
        for(k = 0; k < numk; k++)
        {
			for(b = 0; b < bands ; b++)
				sigmabs[k*bands+b] = 0;
            sigmax[k] = 0;
            sigmay[k] = 0;
            clustersize[k] = 0;
        }
        
		ind = 0;
        for( r = 0; r < height; r++ )
        {
            for( c = 0; c < width; c++ )
            {
                if(klabels[ind] >= 0) //已划分好的聚类
                {
					for(b=0; b<bands; b++)
						sigmabs[klabels[ind]*bands+b] += spectral_vec[ind*bands+b];
                    sigmax[klabels[ind]] += c;
                    sigmay[klabels[ind]] += r;
                    clustersize[klabels[ind]] += 1.0;
                }
                ind++;
            }
        }
        
		for( k = 0; k < numk; k++ )
		{
			if( clustersize[k] <= 0 ) clustersize[k] = 1; //可能存在的未成功聚类的点
			inv[k] = 1.0/clustersize[k];//computing inverse now to multiply, than divide later
		}
		//更新新的聚类中心，此次有疑问，计算的聚类中心坐标不是真实像素点的光谱值
		for( k = 0; k < numk; k++ )
		{
			for(b=0; b<bands; b++)
				kseeds[k*bands+b] = sigmabs[k*bands+b]*inv[k];
			kseedsx[k] = sigmax[k]*inv[k];
			kseedsy[k] = sigmay[k]*inv[k];
		}
	}
    mxFree(sigmabs);
    mxFree(sigmax);
    mxFree(sigmay);
    mxFree(clustersize);
    mxFree(inv);
    mxFree(distvec);
}

/*将一些未聚类像元重新聚类*/
void EnforceSuperpixelConnectivity(int* labels, int width, int height, int numSuperpixels,int* nlabels, int* finalNumberOfLabels)
{
    int i,j,k;
    int n,c,count;
    int x,y;
    int ind;
    int oindex, adjlabel;
    int label;
	
	// 4 邻域    
    const int dx4[4] = {-1,  0,  1,  0};
	const int dy4[4] = { 0, -1,  0,  1};
    
	const int sz = width*height;
    const int SUPSZ = sz/numSuperpixels;
    
	int* xvec = (int*)mxMalloc(sizeof(int)*SUPSZ*10);
	int* yvec = (int*)mxMalloc(sizeof(int)*SUPSZ*10);

	for( i = 0; i < sz; i++ ) nlabels[i] = -1;

    oindex = 0;
    adjlabel = 0;//adjacent label
    label = 0;

	for( j = 0; j < height; j++ )
	{
		for( k = 0; k < width; k++ )
		{
			if( 0 > nlabels[oindex] )
			{
				nlabels[oindex] = label;
				//--------------------
				// Start a new segment
				//--------------------
				xvec[0] = k;
				yvec[0] = j;
				//-------------------------------------------------------
				// Quickly find an adjacent label for use later if needed
				//-------------------------------------------------------
				for( n = 0; n < 4; n++ )
				{
					int x = xvec[0] + dx4[n];
					int y = yvec[0] + dy4[n];
					if( (x >= 0 && x < width) && (y >= 0 && y < height) )
					{
						int nindex = y*width + x;
						if(nlabels[nindex] >= 0) adjlabel = nlabels[nindex];
					}
				}
                
				count = 1;
				for( c = 0; c < count; c++ )
				{
					for( n = 0; n < 4; n++ )
					{
						x = xvec[c] + dx4[n];
						y = yvec[c] + dy4[n];
                        
						if( (x >= 0 && x < width) && (y >= 0 && y < height) )
						{
							int nindex = y*width + x;
                            
							if( 0 > nlabels[nindex] && labels[oindex] == labels[nindex] )
							{
								xvec[count] = x;
								yvec[count] = y;
								nlabels[nindex] = label;
								count++;
							}
						}
                        
					}
				}
				//-------------------------------------------------------
				// If segment size is less then a limit, assign an
				// adjacent label found before, and decrement label count.
				//-------------------------------------------------------
				if(count <= SUPSZ >> 2)
				{
					for( c = 0; c < count; c++ )
					{
                        ind = yvec[c]*width+xvec[c];
						nlabels[ind] = adjlabel;
					}
					label--;
				}
				label++;
			}
			oindex++;
		}
	}
	*finalNumberOfLabels = label;
    
	mxFree(xvec);
	mxFree(yvec);
}

/*
 * 输入参数，8个，第1-4个是遥感数据（一维向量的形式），
 * 第5个是超像素个数，第6个是常量m值，
 * 第7个是采用的相似度测量类型,
 * 第8个是控制输出形式（是否处理未聚类的像素）
 * 
 * 输出参数，4个, 
 * 第1个是聚类标签，第2个是实际聚类数量
 * 第3，4个是聚类中心像元坐标
 **/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])      
{
    int width, height, bands, sz;
	int numSuperpixels = 200;//default value
    double compactness = 0.1;//default value	
    int dist_type = 1;  //距离测度类型，1：ED（缺省值），2：SAD, 3:SID, 4:SAD-SID
    int handle_all = 1; //是否处理所有像元，1：处理（缺省值）， 2：不处理，即返回的labels中存在未聚类的像元
    
	int i, ii, x, y, k ,t;
    
	int* klabels;
    int* clabels;
    
	int step;
    int* seedIndices;
    int numseeds;
    
	double* kseedsx;
    double* kseedsy;
    double* kseeds;  //存放每个种子像元的光谱数据
    
    int* outputNumSuperpixels;
    int* outlabels;
    int finalNumberOfLabels;
    double* outseedx;
    double* outseedy;
    
    int numelements;
    int* dims;
	double* spectral_vec; //存放原始图像数据    
    

    if (nrhs < 4) {
        mexErrMsgTxt("At least 4 argument is required.") ;
    } else if(nrhs > 8) {
        mexErrMsgTxt("Too many input arguments.");
    }
    if(nlhs!=4) {
        mexErrMsgIdAndTxt("SLIC:nlhs","Four outputs required, a labels, the number of labels and the seed positions.");
    }

    //读取输入参数
    numelements = mxGetNumberOfElements(prhs[0]) ; //遥感数据是三维数据，因此传递进来后需要重建
    dims  = (int*)mxGetDimensions(prhs[0]) ;
    spectral_vec  = (double*)mxGetData(prhs[0]) ;//遥感数据本身是double类型的，此处注意三维转为一维时的顺序
    //---------------------------
    width  = mxGetScalar(prhs[2]); //列数
    height  = mxGetScalar(prhs[1]);//行数
    bands  = mxGetScalar(prhs[3]); //波段数
    sz = width*height; //像素个数
    numSuperpixels  = mxGetScalar(prhs[4]);
    compactness     = mxGetScalar(prhs[5]);
    dist_type = mxGetScalar(prhs[6]);
    handle_all = mxGetScalar(prhs[7]);
	    
    //---------------------------
    // Allocate memory
    //---------------------------    
    klabels = (int*)mxMalloc( sizeof(int)         * sz );//original k-means labels
    clabels = (int*)mxMalloc( sizeof(int)         * sz );//corrected labels after enforcing connectivity
    seedIndices = (int*)mxMalloc( sizeof(int)     * sz ); //存放种子的索引值，其实不需要这么大
    
    //---------------------------
    // Find seeds
    //---------------------------
    step = sqrt((double)(sz)/(double)(numSuperpixels))+0.5; //聚类区域的边长，近似正方形邻域
    getSeeds(step, width, height, seedIndices, &numseeds);	
    
    kseedsx    = (double*)mxMalloc( sizeof(double) * numseeds ) ;
    kseedsy    = (double*)mxMalloc( sizeof(double) * numseeds ) ;
    kseeds     = (double*)mxMalloc( sizeof(double) * numseeds * bands ) ; //每行代表一个种子像元
    for(k = 0; k < numseeds; k++)
    {
        kseedsx[k] = seedIndices[k]%width; //列号
        kseedsy[k] = seedIndices[k]/width; //行号
        for(t=0; t<bands; t++)
        {
            kseeds[k*bands+t] = spectral_vec[seedIndices[k]*bands+t];
        }
    }
    //---------------------------
    // Compute superpixels
    //---------------------------
    for(i=0; i<sz; i++)
    {
        klabels[i] = clabels[i] = -1;
    }
    
    PerformSuperpixelSLIC(spectral_vec, kseeds,bands, kseedsx,kseedsy,width,height,numseeds,klabels,step,compactness,dist_type);
    
    //---------------------------
    // Enforce connectivity
    //---------------------------
    if(handle_all == 1)
    {
        EnforceSuperpixelConnectivity(klabels,width,height,numseeds,clabels,&finalNumberOfLabels);
    }
    else 
    {
        for(i=0; i<sz; i++)
        {
            clabels[i] = klabels[i];
            finalNumberOfLabels = numseeds;
        }
    }
        
    //---------------------------
    // Assign output labels
    //---------------------------
    plhs[0] = mxCreateNumericMatrix(1, sz, mxINT32_CLASS,mxREAL);
    outlabels = (int*)mxGetData(plhs[0]);
    for(x = 0; x < sz; x++)
    {
       outlabels[x] = clabels[x]+1;  // 返回的是行优先格式
    }
    //---------------------------
    // Assign number of labels/seeds
    //---------------------------
    plhs[1] = mxCreateNumericMatrix(1,1,mxINT32_CLASS,mxREAL);
    outputNumSuperpixels = (int*)mxGetData(plhs[1]);//gives a void*, cast it to int*
    *outputNumSuperpixels = finalNumberOfLabels;

	plhs[2] = mxCreateDoubleMatrix(1, finalNumberOfLabels, mxREAL);
    outseedx = (double*)mxGetData(plhs[2]);
    for(x = 0; x < finalNumberOfLabels; x++)//copying data from row-major C matrix to column-major MATLAB matrix (i.e. perform transpose)
    {
		outseedx[x] = kseedsx[x]+1; //add 1 because matlab is different with C for array index，列号        
    }

	plhs[3] = mxCreateDoubleMatrix(1, finalNumberOfLabels, mxREAL);
    outseedy = (double*)mxGetData(plhs[3]);
    for(x = 0; x < finalNumberOfLabels; x++)//copying data from row-major C matrix to column-major MATLAB matrix (i.e. perform transpose)
    {
		outseedy[x] = kseedsy[x]+1; //add 1 because matlab is different with C for array index，行号       
    }


    //---------------------------
    // Deallocate memory
    //---------------------------     
    mxFree(klabels);
    mxFree(clabels);
    mxFree(seedIndices);
    mxFree(kseedsx);
    mxFree(kseedsy);
    mxFree(kseeds);
}
