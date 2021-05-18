/* -------------------------------------------------------------------------- */
/* dark.h                                                                     */
/* (c) Yves BORCKMANS 1995                                                    */
/* -------------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <fcntl.h>
#include <io.h>
#include <dos.h>
#include <dir.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <alloc.h>

#define DARK_H             1
#define boolean          int
#define TRUE               1
#define FALSE              0

/* ************************************************************************** */
/* *                               PROTOTYPES                               * */
/* ************************************************************************** */

/*
#ifndef USING_TOOLKIT
boolean  fexists(char *filename);
#endif
*/
boolean  is_gob(char *filename);
boolean  is_lev(char *filename);
long     get_master_index(int f);
long     get_master_entries(int f);
void     set_magic(int f, char *mm);
void     set_master_index(int f, long mi);
void     set_master_entries(int f, long me);
void     seek_master_index(int f);
void     seek_object(int f, long offset);
void     get_object(int f, void *ptr, long size);
void     set_object(int f, void *ptr, long size);
void     save_pos(int f, int mem);
void     rest_pos(int f, int mem);


/* ************************************************************************** */
/* *                               STRUCTURES                               * */
/* ************************************************************************** */

/* GOB_BEGIN
   These are the first bytes of an GOB file.
   GOB_MAGIC       is 'GOB' followed by 0x0A
   MASTERX         is the offset of the MASTER INDEX
*/

typedef struct GOB_BEGIN
  {
   char            GOB_MAGIC[4];
   long            MASTERX;
  };

/* -------------------------------------------------------------------------- */

/* GOB_INDEX_ENTRY
   This is a structure defining one of the entries of the MASTER INDEX.
   IX              is the offset of this entry's data
   LEN             is the length of this entry's data
   NAME            is this entry's name
*/

typedef struct GOB_INDEX_ENTRY
  {
   long            IX;
   long            LEN;
   char            NAME[13];
  };

/* -------------------------------------------------------------------------- */
/* LEV Structures & Typedefs */


typedef struct tagLNF
  {
   float parallax1;
   float parallax2;
  } LNF;

typedef long LVB;
typedef int  VER;
typedef long TEX;
typedef long TNO;
typedef long SCS;
typedef long SNO;
typedef long SEC;
typedef long VNO;
typedef long WLS;
typedef long WNO;

