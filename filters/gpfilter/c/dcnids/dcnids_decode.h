/*
 * Copyright (c) 2005 Jose F. Nieves <nieves@ltp.upr.clu.edu>
 *
 * See LICENSE
 *
 * $Id$
 */
#ifndef DCNIDS_DECODE_H
#define DCNIDS_DECODE_H

#define NIDS_HEADER_SIZE	120	/* message and pdb */
#define NIDS_DBF_CODENAME	"code"  /* parameter name in dbf file */
#define NIDS_DBF_LEVELNAME	"level" /* parameter name in dbf file */

#define NIDS_PDB_MODE_MAINTENANCE	0
#define NIDS_PDB_MODE_CLEAR		1
#define NIDS_PDB_MODE_PRECIPITATION	2

/* packet types */
#define NIDS_PACKET_RADIALS_AF1F		0xaf1f
#define NIDS_PACKET_DIGITAL_RADIALS_16		16

/*
 * When decoding the data packets, we must go to the start of the
 * "individual radials". In bytes:
 * symbologoy block => 10 
 * symbology layer =>  6
 * radial packet header => 14
 */
#define NIDS_PACKET_RADIALS_START_RUNS		30

struct nids_header_st {
  unsigned char header[NIDS_HEADER_SIZE];
  int m_code;
  int m_days;
  unsigned int m_seconds;
  unsigned int m_msglength;	/* file length without header or trailer */
  int m_source;                 /* unused */
  int m_destination;            /* unused */
  int m_numblocks;              /* unused */
  int pdb_lat;
  int pdb_lon;
  int pdb_height;
  int pdb_code;
  int pdb_mode;
  int pdb_version;
  unsigned int pdb_symbol_block_offset;
  unsigned int pdb_graphic_block_offset;
  unsigned int pdb_tabular_block_offset;
  /* derived values */
  unsigned int unixseconds;
  double lat;
  double lon;
};

struct nids_product_symbol_block_st {
  int blockid;		/* should be 1 */
  unsigned int blocklength;
  int numlayers;
  unsigned int psb_layer_blocklength;
};

struct nids_radial_packet_header_st {
  int packet_code;
  int first_bin_index;
  int numbins;
  int center_i;
  int center_j;
  int scale;
  int numradials;
};

struct nids_data_st {
  unsigned char *data;		/* file data excluding 120 byte header*/
  unsigned int data_size;	/* "msg size" - nids header (120) */
  struct nids_header_st nids_header;
  struct nids_product_symbol_block_st psb;
  struct nids_radial_packet_header_st radial_packet_header;
  struct dcnids_polygon_map_st polygon_map;
};

void nids_decode_radials_af1f(struct nids_data_st *nd);
void nids_decode_digital_radials_16(struct nids_data_st *nd);

#endif
