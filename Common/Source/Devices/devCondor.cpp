/*
   LK8000 Tactical Flight Computer -  WWW.LK8000.IT
   Released under GNU/GPL License v.2
   See CREDITS.TXT file for authors and copyrights

   $Id$
*/

#include "externs.h"

#include "devCondor.h"


static BOOL cLXWP0(PDeviceDescriptor_t d, TCHAR *String, NMEA_INFO *pGPS);
static BOOL cLXWP1(PDeviceDescriptor_t d, TCHAR *String, NMEA_INFO *pGPS);
static BOOL cLXWP2(PDeviceDescriptor_t d, TCHAR *String, NMEA_INFO *pGPS);

extern bool UpdateBaroSource(NMEA_INFO* pGPS, const short parserid, const PDeviceDescriptor_t d, const double fAlt);


static BOOL CondorParseNMEA(PDeviceDescriptor_t d, TCHAR *String, NMEA_INFO *pGPS){
  (void)d;
  if(_tcsncmp(TEXT("$LXWP0"), String, 6)==0)
    {
      return cLXWP0(d, &String[7], pGPS);
    } 
  if(_tcsncmp(TEXT("$LXWP1"), String, 6)==0)
    {
      return cLXWP1(d, &String[7], pGPS);
    } 
  if(_tcsncmp(TEXT("$LXWP2"), String, 6)==0)
    {
      return cLXWP2(d, &String[7], pGPS);
    }

  return FALSE;

}

static BOOL CondorIsCondor(PDeviceDescriptor_t d){
  (void)d;
  return(TRUE); 
}


static BOOL CondorIsGPSSource(PDeviceDescriptor_t d){
  (void)d;
  return(TRUE); 
}


static BOOL CondorIsBaroSource(PDeviceDescriptor_t d){
	(void)d;
  return(TRUE);
}


static BOOL CondorLinkTimeout(PDeviceDescriptor_t d){
  (void)d;
  return(TRUE);
}


static BOOL condorInstall(PDeviceDescriptor_t d){

  StartupStore(_T(". Condor device installed%s"),NEWLINE);
  _tcscpy(d->Name, TEXT("Condor"));
  d->ParseNMEA = CondorParseNMEA;
  d->PutMacCready = NULL;
  d->PutBugs = NULL;
  d->PutBallast = NULL;
  d->Open = NULL;
  d->Close = NULL;
  d->Init = NULL;
  d->LinkTimeout = CondorLinkTimeout;
  d->Declare = NULL;
  d->IsGPSSource = CondorIsGPSSource;
  d->IsBaroSource = CondorIsBaroSource;
  d->IsCondor = CondorIsCondor;

  return(TRUE);

}


BOOL condorRegister(void){
  return(devRegister(
    TEXT("Condor"),
    (1l << dfGPS)
    | (1l << dfBaroAlt)
    | (1l << dfSpeed)
    | (1l << dfVario),
    condorInstall
  ));
}


// *****************************************************************************
// local stuff


static BOOL cLXWP1(PDeviceDescriptor_t d, TCHAR *String, NMEA_INFO *pGPS)
{
  //  TCHAR ctemp[80];
  (void)pGPS;
  // do nothing!
  return TRUE;
}


static BOOL cLXWP2(PDeviceDescriptor_t d, TCHAR *String, NMEA_INFO *pGPS)
{
  TCHAR ctemp[80];
  (void)pGPS;

  NMEAParser::ExtractParameter(String,ctemp,0);
  MACCREADY = StrToDouble(ctemp,NULL);
  return TRUE;
}


static BOOL cLXWP0(PDeviceDescriptor_t d, TCHAR *String, NMEA_INFO *pGPS) {
  TCHAR ctemp[80];

  /*
  $LXWP0,Y,222.3,1665.5,1.71,,,,,,239,174,10.1

   0 loger_stored (Y/N)
   1 IAS (kph) ----> Condor uses TAS!
   2 baroaltitude (m)
   3 vario (m/s)
   4-8 unknown
   9 heading of plane
  10 windcourse (deg)
  11 windspeed (kph)

  */
  double alt, airspeed, wspeed, wfrom;
 
  NMEAParser::ExtractParameter(String,ctemp,1);
  airspeed = StrToDouble(ctemp,NULL)/TOKPH;

  NMEAParser::ExtractParameter(String,ctemp,2);
  alt = StrToDouble(ctemp,NULL);

  pGPS->IndicatedAirspeed = airspeed/AirDensityRatio(alt);
  pGPS->TrueAirspeed = airspeed;

  UpdateBaroSource( pGPS, 0,d,  AltitudeToQNHAltitude(alt));

  NMEAParser::ExtractParameter(String,ctemp,3);
  pGPS->Vario = StrToDouble(ctemp,NULL);

  pGPS->AirspeedAvailable = TRUE;
  pGPS->VarioAvailable = TRUE;

  // we don't use heading for wind calculation since... wind is already calculated in condor!!
  NMEAParser::ExtractParameter(String,ctemp,11);
  wspeed=StrToDouble(ctemp,NULL);
  NMEAParser::ExtractParameter(String,ctemp,10);
  wfrom=StrToDouble(ctemp,NULL);

  #if 1 // 120424 fix correct wind setting

  wfrom+=180;
  if (wfrom==360) wfrom=0;
  if (wfrom>360) wfrom-=360;
  wspeed/=3.6;

  pGPS->ExternalWindAvailable = TRUE;
  pGPS->ExternalWindSpeed = wspeed;
  pGPS->ExternalWindDirection = wfrom;

  #else
  if (wspeed>0) {

	wfrom+=180;
	if (wfrom==360) wfrom=0;
	if (wfrom>360) wfrom-=360;
	wspeed/=3.6;

	// do not update if it has not changed
	if ( (wspeed!=CALCULATED_INFO.WindSpeed) || (wfrom != CALCULATED_INFO.WindBearing) ) {

		SetWindEstimate(wspeed, wfrom,9);
		CALCULATED_INFO.WindSpeed=wspeed;
		CALCULATED_INFO.WindBearing=wfrom;

	}
  }
  #endif


  return TRUE;
}
