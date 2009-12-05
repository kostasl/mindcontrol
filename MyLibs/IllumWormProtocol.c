/*
 * WormIllumProtocol.c
 *
 * This library is designed to have objects and functions used to
 * write, analyze and excecute illumination protocols written for worms.
 *
 * As such it relies on the high level WormAnalysis library.
 * But Other libraries like WriteOutWorm likely depend upon it.
 *
 *
 *  Created on: Nov 11, 2009
 *      Author: Andy
 */

#include <stdio.h>
#include <time.h>

//OpenCV Headers
#include <cxcore.h>
#include <highgui.h>
#include <cv.h>

// Andy's Libraries

#include "AndysOpenCVLib.h"
#include "WormAnalysis.h"
#include "IllumWormProtocol.h"
#include "version.h"



/*******************************************/
/*
 * Protocol Objects
 */
/*******************************************/

/*
 * Create a Protocol Object and set all of its values to zero or NULL
 * The Protocol object has some descriptions and a CvSeq object that
 * points to sequences of polygons for illumination.
 * Each step can contain an arbitrary number of polygons.
 * Each polygon can contain an arbitrary number of points.
 *
 */
Protocol* CreateProtocolObject(){
	Protocol* MyProto= (Protocol*) malloc(sizeof(Protocol*));
	MyProto->GridSize.height=0;
	MyProto->GridSize.width=0;
	MyProto->Filename=NULL;
	MyProto->Description=NULL;
	MyProto->Steps=NULL;
	MyProto->memory=cvCreateMemStorage();
	return MyProto;

}



/*
 * Write everything out to YAML
 *
 */
void WriteProtocolToYAML(Protocol* myP){
	/** Open file for writing **/
	CvFileStorage* fs=cvOpenFileStorage(myP->Filename,myP->memory,CV_STORAGE_WRITE);
	if (fs==0){
		printf("fs is zero! Could you have specified the wrong directory?\n");
		return;
	}
	printf("hey\n");
	/** Write out Generic comments **/
	cvWriteComment(fs, "Illumination Protocol:",0);
	cvWriteComment(fs, "Generated by the IlluminationWormProtocol Library \nmade by leifer@fas.harvard.edu",0);
	cvWriteComment(fs, "\nSoftware Version Information:",0);
	cvWriteComment(fs, build_git_sha,0);
	cvWriteComment(fs, build_git_time,0);
	cvWriteComment(fs, "\n",0);

	/** Write out Protocol **/
	cvStartWriteStruct(fs,"Protocol",CV_NODE_MAP,NULL);
		if (myP->Filename!=NULL) cvWriteString(fs,"Filename",myP->Filename);
		if (myP->Description!=NULL)  cvWriteString(fs,"Description",myP->Description);
		cvStartWriteStruct(fs,"GridSize",CV_NODE_MAP,NULL);
			cvWriteInt(fs,"height",myP->GridSize.height);
			cvWriteInt(fs,"width",myP->GridSize.width);
		cvEndWriteStruct(fs);
		printf("yo\n");
		/** Write Out Steps **/
		cvStartWriteStruct(fs,"Steps",CV_NODE_SEQ,NULL);
		int j;
		int jtot=myP->Steps->total;
		for (j = 0; j < jtot; ++j) {
			CvSeq* CurrentMontage=NULL;
			cvSeqPopFront(myP->Steps,&CurrentMontage);
			cvStartWriteStruct(fs,NULL,CV_NODE_SEQ,NULL);

			int k;
			printf("CurrentMontage->total=%d\n",CurrentMontage->total);
			int ktot=CurrentMontage->total;
			for (k = 0; k < ktot; ++k) {
				WormPolygon* CurrentPolygon=NULL;
				cvSeqPopFront(CurrentMontage, &CurrentPolygon);
				printf("CurrentPolygon->total=%d\n",CurrentPolygon->Points->total);

				cvStartWriteStruct(fs,NULL,CV_NODE_SEQ,NULL);
				int l;
				int ltot=CurrentPolygon->Points->total;
				for (l = 0; l < ltot; ++l) {

					CvPoint CurrentPt;
					cvSeqPopFront(CurrentPolygon->Points,&CurrentPt);
					cvStartWriteStruct(fs,NULL,CV_NODE_MAP,NULL);
						cvWriteInt(fs,"x",CurrentPt.x);
						cvWriteInt(fs,"y",CurrentPt.y);
					cvEndWriteStruct(fs);

				}
				cvEndWriteStruct(fs);

			}
			cvEndWriteStruct(fs);

		}
		cvEndWriteStruct(fs);
	cvEndWriteStruct(fs);
}


void DestroyProtocolObject(Protocol** MyProto){
	/** **/
	/** if BLAH is not NULL release BLAH **/

	cvReleaseMemStorage(&(*MyProto)->memory);
	free(MyProto);
	*MyProto=NULL;
}





/*******************************************/
/*
 * Steps Objects
 */
/*******************************************/


/*
 * A steps object is a cvSeq containing pointers to
 * Illumination Montages (whcih are in turn cvSeq's of pointers to Polygons).
 *
 */
CvSeq* CreateStepsObject(CvMemStorage* memory){
	if (memory==NULL) {
		printf("ERROR! memory is null in CreateStepsObject()!\n");
		return NULL;
	}
	CvSeq* mySteps=cvCreateSeq(CV_SEQ_ELTYPE_PTR,sizeof(CvSeq),sizeof(CvSeq*),memory);
	return mySteps;
}




/*******************************************/
/*
 * Illumination Objects
 */
/*******************************************/

/*
 * An illumination montage consists of a sequence of pointers to polygons
 *
 */
CvSeq* CreateIlluminationMontage(CvMemStorage* memory){
	CvSeq* myIllumMontage=cvCreateSeq(CV_SEQ_ELTYPE_PTR,sizeof(CvSeq),sizeof(WormPolygon*),memory);
	return myIllumMontage;
}



/*******************************************/
/*
 * Polygon Objects
 */
/*******************************************/

/*
 * Given a memory object, this will create a polygon object that is a CvSeq.
 *
 */
WormPolygon* CreateWormPolygon(CvMemStorage* memory,CvSize mySize){
	WormPolygon* myPoly=(WormPolygon*) malloc(sizeof(WormPolygon));
	myPoly->Points=cvCreateSeq(CV_SEQ_ELTYPE_POINT,sizeof(CvSeq),sizeof(CvPoint),memory);
	myPoly->GridSize=mySize;
	return myPoly;
}

/*
 * Destroys a polygon but doesn't free up the CvMemStorage that that polygon used
 *
 */
void DestroyWormPolygon(WormPolygon** myPoly){
	free(myPoly);
	*myPoly=NULL;
}


