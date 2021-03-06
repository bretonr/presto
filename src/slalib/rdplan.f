      SUBROUTINE sla_RDPLAN (DATE, NP, ELONG, PHI, RA, DEC, DIAM)
*+
*     - - - - - - -
*      R D P L A N
*     - - - - - - -
*
*  Approximate topocentric apparent RA,Dec of a planet, and its
*  angular diameter.
*
*  Given:
*     DATE        d       MJD of observation (JD - 2400000.5)
*     NP          i       planet: 1 = Mercury
*                                 2 = Venus
*                                 3 = Moon
*                                 4 = Mars
*                                 5 = Jupiter
*                                 6 = Saturn
*                                 7 = Uranus
*                                 8 = Neptune
*                                 9 = Pluto
*                              else = Sun
*     ELONG,PHI   d       observer's east longitude and geodetic
*                                               latitude (radians)
*
*  Returned:
*     RA,DEC      d        RA, Dec (topocentric apparent, radians)
*     DIAM        d        angular diameter (equatorial, radians)
*
*  Notes:
*
*  1  The date is in a dynamical timescale (TDB, formerly ET) and is
*     in the form of a Modified Julian Date (JD-2400000.5).  For all
*     practical purposes, TT can be used instead of TDB, and for many
*     applications UT will do (except for the Moon).
*
*  2  The longitude and latitude allow correction for geocentric
*     parallax.  This is a major effect for the Moon, but in the
*     context of the limited accuracy of the present routine its
*     effect on planetary positions is small (negligible for the
*     outer planets).  Geocentric positions can be generated by
*     appropriate use of the routines sla_DMOON and sla_PLANET.
*
*  3  The direction accuracy (arcsec, 1000-3000AD) is of order:
*
*            Sun              5
*            Mercury          2
*            Venus           10
*            Moon            30
*            Mars            50
*            Jupiter         90
*            Saturn          90
*            Uranus          90
*            Neptune         10
*            Pluto            1   (1885-2099AD only)
*
*     The angular diameter accuracy is about 0.4% for the Moon,
*     and 0.01% or better for the Sun and planets.
*
*  See the sla_PLANET routine for references.
*
*  Called: sla_GMST, sla_DT, sla_EPJ, sla_DMOON, sla_PVOBS, sla_PRENUT,
*          sla_PLANET, sla_DMXV, sla_DCC2S, sla_DRANRM
*
*  P.T.Wallace   Starlink   26 May 1997
*
*  Copyright (C) 1997 Rutherford Appleton Laboratory
*
*  License:
*    This program is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 2 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program (see SLA_CONDITIONS); if not, write to the 
*    Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
*    Boston, MA  02111-1307  USA
*
*-

      IMPLICIT NONE

      DOUBLE PRECISION DATE
      INTEGER NP
      DOUBLE PRECISION ELONG,PHI,RA,DEC,DIAM

*  AU in km
      DOUBLE PRECISION AUKM
      PARAMETER (AUKM=1.49597870D8)

*  Light time for unit distance (sec)
      DOUBLE PRECISION TAU
      PARAMETER (TAU=499.004782D0)

      INTEGER IP,J,I
      DOUBLE PRECISION EQRAU(0:9),STL,VGM(6),V(6),RMAT(3,3),
     :                 VSE(6),VSG(6),VSP(6),VGO(6),DX,DY,DZ,R,TL
      DOUBLE PRECISION sla_GMST,sla_DT,sla_EPJ,sla_DRANRM

*  Equatorial radii (km)
      DATA EQRAU / 696000D0,2439.7D0,6051.9D0,1738D0,3397D0,71492D0,
     :             60268D0,25559D0,24764D0,1151D0 /



*  Classify NP
      IP=NP
      IF (IP.LT.0.OR.IP.GT.9) IP=0

*  Approximate local ST
      STL=sla_GMST(DATE-sla_DT(sla_EPJ(DATE))/86400D0)+ELONG

*  Geocentre to Moon (mean of date)
      CALL sla_DMOON(DATE,V)

*  Nutation to true of date
      CALL sla_NUT(DATE,RMAT)
      CALL sla_DMXV(RMAT,V,VGM)
      CALL sla_DMXV(RMAT,V(4),VGM(4))

*  Moon?
      IF (IP.EQ.3) THEN

*     Yes: geocentre to Moon (true of date)
         DO I=1,6
            V(I)=VGM(I)
         END DO
      ELSE

*     No: precession/nutation matrix, J2000 to date
         CALL sla_PRENUT(2000D0,DATE,RMAT)

*     Sun to Earth-Moon Barycentre (J2000)
         CALL sla_PLANET(DATE,3,V,J)

*     Precession and nutation to date
         CALL sla_DMXV(RMAT,V,VSE)
         CALL sla_DMXV(RMAT,V(4),VSE(4))

*     Sun to geocentre (true of date)
         DO I=1,6
            VSG(I)=VSE(I)-0.012150581D0*VGM(I)
         END DO

*     Sun?
         IF (IP.EQ.0) THEN

*        Yes: geocentre to Sun
            DO I=1,6
               V(I)=-VSG(I)
            END DO
         ELSE

*        No: Sun to Planet (J2000)
            CALL sla_PLANET(DATE,IP,V,J)

*        Precession and nutation to date
            CALL sla_DMXV(RMAT,V,VSP)
            CALL sla_DMXV(RMAT,V(4),VSP(4))

*        Geocentre to planet
            DO I=1,6
               V(I)=VSP(I)-VSG(I)
            END DO
         END IF
      END IF

*  Refer to origin at the observer
      CALL sla_PVOBS(PHI,0D0,STL,VGO)
      DO I=1,6
         V(I)=V(I)-VGO(I)
      END DO

*  Geometric distance (AU)
      DX=V(1)
      DY=V(2)
      DZ=V(3)
      R=SQRT(DX*DX+DY*DY+DZ*DZ)

*  Light time (sec)
      TL=TAU*R

*  Correct position for planetary aberration
      DO I=1,3
         V(I)=V(I)-TL*V(I+3)
      END DO

*  To RA,Dec
      CALL sla_DCC2S(V,RA,DEC)
      RA=sla_DRANRM(RA)

*  Angular diameter (radians)
      DIAM=2D0*ASIN(EQRAU(IP)/(R*AUKM))

      END
