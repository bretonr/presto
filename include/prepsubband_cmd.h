#ifndef __prepsubband_cmd__
#define __prepsubband_cmd__
/*****
  command line parser interface -- generated by clig 
  (http://wsd.iitb.fhg.de/~kir/clighome/)

  The command line parser `clig':
  (C) 1995---2001 Harald Kirsch (kirschh@lionbioscience.com)
*****/

typedef struct s_Cmdline {
  /***** -o: Root of the output file names */
  char outfileP;
  char* outfile;
  int outfileC;
  /***** -pkmb: Raw data in Parkes Multibeam format */
  char pkmbP;
  /***** -bcpm: Raw data in Berkeley-Caltech Pulsar Machine (BPP) format */
  char bcpmP;
  /***** -if: For BPP format only:  A specific IF to use. */
  char ifsP;
  int ifs;
  int ifsC;
  /***** -wapp: Raw data in Wideband Arecibo Pulsar Processor (WAPP) format */
  char wappP;
  /***** -clip: For WAPP format only:  Time-domain sigma to use for clipping.  If zero, no clipping is performed. */
  char clipP;
  float clip;
  int clipC;
  /***** -numout: Output this many values.  If there are not enough values in the original data file, will pad the output file with the average value */
  char numoutP;
  int numout;
  int numoutC;
  /***** -nobary: Do not barycenter the data */
  char nobaryP;
  /***** -DE405: Use the DE405 ephemeris for barycentering instead of DE200 (the default) */
  char de405P;
  /***** -lodm: The lowest dispersion measure to de-disperse (cm^-3 pc) */
  char lodmP;
  double lodm;
  int lodmC;
  /***** -dmstep: The stepsize in dispersion measure to use(cm^-3 pc) */
  char dmstepP;
  double dmstep;
  int dmstepC;
  /***** -numdms: The number of DMs to de-disperse */
  char numdmsP;
  int numdms;
  int numdmsC;
  /***** -numsub: The number of sub-bands to use */
  char numsubP;
  int numsub;
  int numsubC;
  /***** -downsamp: The number of neighboring bins to co-add */
  char downsampP;
  int downsamp;
  int downsampC;
  /***** -mask: File containing masking information to use */
  char maskfileP;
  char* maskfile;
  int maskfileC;
  /***** uninterpreted command line parameters */
  int argc;
  /*@null*/char **argv;
  /***** the whole command line concatenated */
  char *full_cmd_line;
} Cmdline;


extern char *Program;
extern void usage(void);
extern /*@shared*/Cmdline *parseCmdline(int argc, char **argv);

extern void showOptionValues(void);

#endif

