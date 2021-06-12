unit GLunit;

{$MODE Delphi}

interface
uses Windows, misc_utils;

type
  INT            = Integer;
  UNSIGNED_INT   = Cardinal;
  UNSIGNED_CHAR  = Byte;
  SIGNED_CHAR    = ShortInt;
  SHORT          = SmallInt;
  UNSIGNED_SHORT = Word;
  FLOAT          = Single;
  DOUBLE_        = Double;

type
  GLenum        = UNSIGNED_INT;
  GLboolean     = Boolean;      {unsigned char}
  PGLboolean    = ^GLboolean;
  GLbitfield    = UNSIGNED_INT;
  GLbyte        = SIGNED_CHAR;
  PGLbyte       = ^GLbyte;
  GLshort       = SHORT;
  PGLshort      = ^GLshort;
  GLint         = INT;
  PGLint        = ^GLint;
  GLsizei       = INT;
  GLubyte       = UNSIGNED_CHAR;
  PGLubyte      = ^GLubyte;
  GLushort      = UNSIGNED_SHORT;
  PGLushort     = ^GLushort;
  GLuint        = UNSIGNED_INT;
  PGLuint       = ^GLuint;
  GLfloat       = FLOAT;
  PGLfloat      = ^GLfloat;
  GLclampf      = FLOAT;
  GLdouble      = DOUBLE_;
  PGLdouble     = ^GLdouble;
  GLclampd      = DOUBLE_;
  {void GLvoid;}


// AccumOp
const
  GL_ACCUM                  = $0100;
  GL_LOAD                   = $0101;
  GL_RETURN                 = $0102;
  GL_MULT                   = $0103;
  GL_ADD                    = $0104;

// AlphaFunction
const
  GL_NEVER                  = $0200;
  GL_LESS                   = $0201;
  GL_EQUAL                  = $0202;
  GL_LEQUAL                 = $0203;
  GL_GREATER                = $0204;
  GL_NOTEQUAL               = $0205;
  GL_GEQUAL                 = $0206;
  GL_ALWAYS                 = $0207;

// AttribMask
const
  GL_CURRENT_BIT            = $00000001;
  GL_POINT_BIT              = $00000002;
  GL_LINE_BIT               = $00000004;
  GL_POLYGON_BIT            = $00000008;
  GL_POLYGON_STIPPLE_BIT    = $00000010;
  GL_PIXEL_MODE_BIT         = $00000020;
  GL_LIGHTING_BIT           = $00000040;
  GL_FOG_BIT                = $00000080;
  GL_DEPTH_BUFFER_BIT       = $00000100;
  GL_ACCUM_BUFFER_BIT       = $00000200;
  GL_STENCIL_BUFFER_BIT     = $00000400;
  GL_VIEWPORT_BIT           = $00000800;
  GL_TRANSFORM_BIT          = $00001000;
  GL_ENABLE_BIT             = $00002000;
  GL_COLOR_BUFFER_BIT       = $00004000;
  GL_HINT_BIT               = $00008000;
  GL_EVAL_BIT               = $00010000;
  GL_LIST_BIT               = $00020000;
  GL_TEXTURE_BIT            = $00040000;
  GL_SCISSOR_BIT            = $00080000;
  GL_ALL_ATTRIB_BITS        = $000fffff;

// BeginMode
const
  GL_POINTS                 = $0000;
  GL_LINES                  = $0001;
  GL_LINE_LOOP              = $0002;
  GL_LINE_STRIP             = $0003;
  GL_TRIANGLES              = $0004;
  GL_TRIANGLE_STRIP         = $0005;
  GL_TRIANGLE_FAN           = $0006;
  GL_QUADS                  = $0007;
  GL_QUAD_STRIP             = $0008;
  GL_POLYGON                = $0009;

// BlendingFactorDest
const
(*GL_ZERO *)
(*GL_ONE *)
  GL_ZERO                   = 0;
  GL_ONE                    = 1;
  GL_SRC_COLOR              = $0300;
  GL_ONE_MINUS_SRC_COLOR    = $0301;
  GL_SRC_ALPHA              = $0302;
  GL_ONE_MINUS_SRC_ALPHA    = $0303;
  GL_DST_ALPHA              = $0304;
  GL_ONE_MINUS_DST_ALPHA    = $0305;
(*GL_SRC_ALPHA *)
(*GL_ONE_MINUS_SRC_ALPHA *)
(*GL_DST_ALPHA *)
(*GL_ONE_MINUS_DST_ALPHA *)

// BlendingFactorSrc
const
  GL_DST_COLOR              = $0306;
  GL_ONE_MINUS_DST_COLOR    = $0307;
  GL_SRC_ALPHA_SATURATE     = $0308;

// Boolean
const
  GL_TRUE                   = True;
  GL_FALSE                  = False;

// ClearBufferMask
(*GL_COLOR_BUFFER_BIT*)
(*GL_ACCUM_BUFFER_BIT*)
(*GL_STENCIL_BUFFER_BIT*)
(*GL_DEPTH_BUFFER_BIT*)

// ClipPlaneName
const
  GL_CLIP_PLANE0            = $3000;
  GL_CLIP_PLANE1            = $3001;
  GL_CLIP_PLANE2            = $3002;
  GL_CLIP_PLANE3            = $3003;
  GL_CLIP_PLANE4            = $3004;
  GL_CLIP_PLANE5            = $3005;

// ColorMaterialFace
(*GL_FRONT*)
(*GL_BACK*)
(*GL_FRONT_AND_BACK*)

// ColorMaterialParameter
(*GL_AMBIENT*)
(*GL_DIFFUSE*)
(*GL_SPECULAR*)
(*GL_EMISSION*)
(*GL_AMBIENT_AND_DIFFUSE*)

// ColorPointerType
(*GL_BYTE*)
(*GL_UNSIGNED_BYTE*)
(*GL_SHORT*)
(*GL_UNSIGNED_SHORT*)
(*GL_INT*)
(*GL_UNSIGNED_INT*)
(*GL_FLOAT*)
(*GL_DOUBLE_EXT*)

// CullFaceMode
(*GL_FRONT*)
(*GL_BACK*)
(*GL_FRONT_AND_BACK*)

// DepthFunction
(*GL_NEVER*)
(*GL_LESS*)
(*GL_EQUAL*)
(*GL_LEQUAL*)
(*GL_GREATER*)
(*GL_NOTEQUAL*)
(*GL_GEQUAL*)
(*GL_ALWAYS*)

// DrawBufferMode
const
  GL_NONE                   = 0;
  GL_FRONT_LEFT             = $0400;
  GL_FRONT_RIGHT            = $0401;
  GL_BACK_LEFT              = $0402;
  GL_BACK_RIGHT             = $0403;
  GL_FRONT                  = $0404;
  GL_BACK                   = $0405;
  GL_LEFT                   = $0406;
  GL_RIGHT                  = $0407;
  GL_FRONT_AND_BACK         = $0408;
  GL_AUX0                   = $0409;
  GL_AUX1                   = $040A;
  GL_AUX2                   = $040B;
  GL_AUX3                   = $040C;

// Enable
(*GL_FOG*)
(*GL_LIGHTING*)
(*GL_TEXTURE_1D*)
(*GL_TEXTURE_2D*)
(*GL_LINE_STIPPLE*)
(*GL_POLYGON_STIPPLE*)
(*GL_CULL_FACE*)
(*GL_ALPHA_TEST*)
(*GL_BLEND*)
(*GL_LOGIC_OP*)
(*GL_DITHER*)
(*GL_STENCIL_TEST*)
(*GL_DEPTH_TEST*)
(*GL_CLIP_PLANE0*)
(*GL_CLIP_PLANE1*)
(*GL_CLIP_PLANE2*)
(*GL_CLIP_PLANE3*)
(*GL_CLIP_PLANE4*)
(*GL_CLIP_PLANE5*)
(*GL_LIGHT0*)
(*GL_LIGHT1*)
(*GL_LIGHT2*)
(*GL_LIGHT3*)
(*GL_LIGHT4*)
(*GL_LIGHT5*)
(*GL_LIGHT6*)
(*GL_LIGHT7*)
(*GL_TEXTURE_GEN_S*)
(*GL_TEXTURE_GEN_T*)
(*GL_TEXTURE_GEN_R*)
(*GL_TEXTURE_GEN_Q*)
(*GL_MAP1_VERTEX_3*)
(*GL_MAP1_VERTEX_4*)
(*GL_MAP1_COLOR_4*)
(*GL_MAP1_INDEX*)
(*GL_MAP1_NORMAL*)
(*GL_MAP1_TEXTURE_COORD_1*)
(*GL_MAP1_TEXTURE_COORD_2*)
(*GL_MAP1_TEXTURE_COORD_3*)
(*GL_MAP1_TEXTURE_COORD_4*)
(*GL_MAP2_VERTEX_3*)
(*GL_MAP2_VERTEX_4*)
(*GL_MAP2_COLOR_4*)
(*GL_MAP2_INDEX*)
(*GL_MAP2_NORMAL*)
(*GL_MAP2_TEXTURE_COORD_1*)
(*GL_MAP2_TEXTURE_COORD_2*)
(*GL_MAP2_TEXTURE_COORD_3*)
(*GL_MAP2_TEXTURE_COORD_4*)
(*GL_POINT_SMOOTH*)
(*GL_LINE_SMOOTH*)
(*GL_POLYGON_SMOOTH*)
(*GL_SCISSOR_TEST*)
(*GL_COLOR_MATERIAL*)
(*GL_NORMALIZE*)
(*GL_AUTO_NORMAL*)
(*GL_VERTEX_ARRAY_EXT*)
(*GL_NORMAL_ARRAY_EXT*)
(*GL_COLOR_ARRAY_EXT*)
(*GL_INDEX_ARRAY_EXT*)
(*GL_TEXTURE_COORD_ARRAY_EXT*)
(*GL_EDGE_FLAG_ARRAY_EXT*)

// ErrorCode
const
  GL_NO_ERROR               = 0;
  GL_INVALID_ENUM           = $0500;
  GL_INVALID_VALUE          = $0501;
  GL_INVALID_OPERATION      = $0502;
  GL_STACK_OVERFLOW         = $0503;
  GL_STACK_UNDERFLOW        = $0504;
  GL_OUT_OF_MEMORY          = $0505;

// FeedBackMode
const
  GL_2D                     = $0600;
  GL_3D                     = $0601;
  GL_3D_COLOR               = $0602;
  GL_3D_COLOR_TEXTURE       = $0603;
  GL_4D_COLOR_TEXTURE       = $0604;

// FeedBackToken
const
  GL_PASS_THROUGH_TOKEN     = $0700;
  GL_POINT_TOKEN            = $0701;
  GL_LINE_TOKEN             = $0702;
  GL_POLYGON_TOKEN          = $0703;
  GL_BITMAP_TOKEN           = $0704;
  GL_DRAW_PIXEL_TOKEN       = $0705;
  GL_COPY_PIXEL_TOKEN       = $0706;
  GL_LINE_RESET_TOKEN       = $0707;

// FogMode
(*GL_LINEAR*)
const
  GL_EXP                    = $0800;
  GL_EXP2                   = $0801;

// FogParameter
(*GL_FOG_COLOR*)
(*GL_FOG_DENSITY*)
(*GL_FOG_END*)
(*GL_FOG_INDEX*)
(*GL_FOG_MODE*)
(*GL_FOG_START*)

// FrontFaceDirection
const
  GL_CW                     = $0900;
  GL_CCW                    = $0901;

// GetMapTarget
const
  GL_COEFF                  = $0A00;
  GL_ORDER                  = $0A01;
  GL_DOMAIN                 = $0A02;

// GetPixelMap
(*GL_PIXEL_MAP_I_TO_I*)
(*GL_PIXEL_MAP_S_TO_S*)
(*GL_PIXEL_MAP_I_TO_R*)
(*GL_PIXEL_MAP_I_TO_G*)
(*GL_PIXEL_MAP_I_TO_B*)
(*GL_PIXEL_MAP_I_TO_A*)
(*GL_PIXEL_MAP_R_TO_R*)
(*GL_PIXEL_MAP_G_TO_G*)
(*GL_PIXEL_MAP_B_TO_B*)
(*GL_PIXEL_MAP_A_TO_A*)

// GetPointerTarget
(*GL_VERTEX_ARRAY_POINTER_EXT*)
(*GL_NORMAL_ARRAY_POINTER_EXT*)
(*GL_COLOR_ARRAY_POINTER_EXT*)
(*GL_INDEX_ARRAY_POINTER_EXT*)
(*GL_TEXTURE_COORD_ARRAY_POINTER_EXT*)
(*GL_EDGE_FLAG_ARRAY_POINTER_EXT*)

// GetTarget
const
  GL_CURRENT_COLOR                  = $0B00;
  GL_CURRENT_INDEX                  = $0B01;
  GL_CURRENT_NORMAL                 = $0B02;
  GL_CURRENT_TEXTURE_COORDS         = $0B03;
  GL_CURRENT_RASTER_COLOR           = $0B04;
  GL_CURRENT_RASTER_INDEX           = $0B05;
  GL_CURRENT_RASTER_TEXTURE_COORDS  = $0B06;
  GL_CURRENT_RASTER_POSITION        = $0B07;
  GL_CURRENT_RASTER_POSITION_VALID  = $0B08;
  GL_CURRENT_RASTER_DISTANCE        = $0B09;
  GL_POINT_SMOOTH                   = $0B10;
  GL_POINT_SIZE                     = $0B11;
  GL_POINT_SIZE_RANGE               = $0B12;
  GL_POINT_SIZE_GRANULARITY         = $0B13;
  GL_LINE_SMOOTH                    = $0B20;
  GL_LINE_WIDTH                     = $0B21;
  GL_LINE_WIDTH_RANGE               = $0B22;
  GL_LINE_WIDTH_GRANULARITY         = $0B23;
  GL_LINE_STIPPLE                   = $0B24;
  GL_LINE_STIPPLE_PATTERN           = $0B25;
  GL_LINE_STIPPLE_REPEAT            = $0B26;
  GL_LIST_MODE                      = $0B30;
  GL_MAX_LIST_NESTING               = $0B31;
  GL_LIST_BASE                      = $0B32;
  GL_LIST_INDEX                     = $0B33;
  GL_POLYGON_MODE                   = $0B40;
  GL_POLYGON_SMOOTH                 = $0B41;
  GL_POLYGON_STIPPLE                = $0B42;
  GL_EDGE_FLAG                      = $0B43;
  GL_CULL_FACE                      = $0B44;
  GL_CULL_FACE_MODE                 = $0B45;
  GL_FRONT_FACE                     = $0B46;
  GL_LIGHTING                       = $0B50;
  GL_LIGHT_MODEL_LOCAL_VIEWER       = $0B51;
  GL_LIGHT_MODEL_TWO_SIDE           = $0B52;
  GL_LIGHT_MODEL_AMBIENT            = $0B53;
  GL_SHADE_MODEL                    = $0B54;
  GL_COLOR_MATERIAL_FACE            = $0B55;
  GL_COLOR_MATERIAL_PARAMETER       = $0B56;
  GL_COLOR_MATERIAL                 = $0B57;
  GL_FOG                            = $0B60;
  GL_FOG_INDEX                      = $0B61;
  GL_FOG_DENSITY                    = $0B62;
  GL_FOG_START                      = $0B63;
  GL_FOG_END                        = $0B64;
  GL_FOG_MODE                       = $0B65;
  GL_FOG_COLOR                      = $0B66;
  GL_DEPTH_RANGE                    = $0B70;
  GL_DEPTH_TEST                     = $0B71;
  GL_DEPTH_WRITEMASK                = $0B72;
  GL_DEPTH_CLEAR_VALUE              = $0B73;
  GL_DEPTH_FUNC                     = $0B74;
  GL_ACCUM_CLEAR_VALUE              = $0B80;
  GL_STENCIL_TEST                   = $0B90;
  GL_STENCIL_CLEAR_VALUE            = $0B91;
  GL_STENCIL_FUNC                   = $0B92;
  GL_STENCIL_VALUE_MASK             = $0B93;
  GL_STENCIL_FAIL                   = $0B94;
  GL_STENCIL_PASS_DEPTH_FAIL        = $0B95;
  GL_STENCIL_PASS_DEPTH_PASS        = $0B96;
  GL_STENCIL_REF                    = $0B97;
  GL_STENCIL_WRITEMASK              = $0B98;
  GL_MATRIX_MODE                    = $0BA0;
  GL_NORMALIZE                      = $0BA1;
  GL_VIEWPORT                       = $0BA2;
  GL_MODELVIEW_STACK_DEPTH          = $0BA3;
  GL_PROJECTION_STACK_DEPTH         = $0BA4;
  GL_TEXTURE_STACK_DEPTH            = $0BA5;
  GL_MODELVIEW_MATRIX               = $0BA6;
  GL_PROJECTION_MATRIX              = $0BA7;
  GL_TEXTURE_MATRIX                 = $0BA8;
  GL_ATTRIB_STACK_DEPTH             = $0BB0;
  GL_ALPHA_TEST                     = $0BC0;
  GL_ALPHA_TEST_FUNC                = $0BC1;
  GL_ALPHA_TEST_REF                 = $0BC2;
  GL_DITHER                         = $0BD0;
  GL_BLEND_DST                      = $0BE0;
  GL_BLEND_SRC                      = $0BE1;
  GL_BLEND                          = $0BE2;
  GL_LOGIC_OP_MODE                  = $0BF0;
  GL_LOGIC_OP                       = $0BF1;
  GL_AUX_BUFFERS                    = $0C00;
  GL_DRAW_BUFFER                    = $0C01;
  GL_READ_BUFFER                    = $0C02;
  GL_SCISSOR_BOX                    = $0C10;
  GL_SCISSOR_TEST                   = $0C11;
  GL_INDEX_CLEAR_VALUE              = $0C20;
  GL_INDEX_WRITEMASK                = $0C21;
  GL_COLOR_CLEAR_VALUE              = $0C22;
  GL_COLOR_WRITEMASK                = $0C23;
  GL_INDEX_MODE                     = $0C30;
  GL_RGBA_MODE                      = $0C31;
  GL_DOUBLEBUFFER                   = $0C32;
  GL_STEREO                         = $0C33;
  GL_RENDER_MODE                    = $0C40;
  GL_PERSPECTIVE_CORRECTION_HINT    = $0C50;
  GL_POINT_SMOOTH_HINT              = $0C51;
  GL_LINE_SMOOTH_HINT               = $0C52;
  GL_POLYGON_SMOOTH_HINT            = $0C53;
  GL_FOG_HINT                       = $0C54;
  GL_TEXTURE_GEN_S                  = $0C60;
  GL_TEXTURE_GEN_T                  = $0C61;
  GL_TEXTURE_GEN_R                  = $0C62;
  GL_TEXTURE_GEN_Q                  = $0C63;
  GL_PIXEL_MAP_I_TO_I               = $0C70;
  GL_PIXEL_MAP_S_TO_S               = $0C71;
  GL_PIXEL_MAP_I_TO_R               = $0C72;
  GL_PIXEL_MAP_I_TO_G               = $0C73;
  GL_PIXEL_MAP_I_TO_B               = $0C74;
  GL_PIXEL_MAP_I_TO_A               = $0C75;
  GL_PIXEL_MAP_R_TO_R               = $0C76;
  GL_PIXEL_MAP_G_TO_G               = $0C77;
  GL_PIXEL_MAP_B_TO_B               = $0C78;
  GL_PIXEL_MAP_A_TO_A               = $0C79;
  GL_PIXEL_MAP_I_TO_I_SIZE          = $0CB0;
  GL_PIXEL_MAP_S_TO_S_SIZE          = $0CB1;
  GL_PIXEL_MAP_I_TO_R_SIZE          = $0CB2;
  GL_PIXEL_MAP_I_TO_G_SIZE          = $0CB3;
  GL_PIXEL_MAP_I_TO_B_SIZE          = $0CB4;
  GL_PIXEL_MAP_I_TO_A_SIZE          = $0CB5;
  GL_PIXEL_MAP_R_TO_R_SIZE          = $0CB6;
  GL_PIXEL_MAP_G_TO_G_SIZE          = $0CB7;
  GL_PIXEL_MAP_B_TO_B_SIZE          = $0CB8;
  GL_PIXEL_MAP_A_TO_A_SIZE          = $0CB9;
  GL_UNPACK_SWAP_BYTES              = $0CF0;
  GL_UNPACK_LSB_FIRST               = $0CF1;
  GL_UNPACK_ROW_LENGTH              = $0CF2;
  GL_UNPACK_SKIP_ROWS               = $0CF3;
  GL_UNPACK_SKIP_PIXELS             = $0CF4;
  GL_UNPACK_ALIGNMENT               = $0CF5;
  GL_PACK_SWAP_BYTES                = $0D00;
  GL_PACK_LSB_FIRST                 = $0D01;
  GL_PACK_ROW_LENGTH                = $0D02;
  GL_PACK_SKIP_ROWS                 = $0D03;
  GL_PACK_SKIP_PIXELS               = $0D04;
  GL_PACK_ALIGNMENT                 = $0D05;
  GL_MAP_COLOR                      = $0D10;
  GL_MAP_STENCIL                    = $0D11;
  GL_INDEX_SHIFT                    = $0D12;
  GL_INDEX_OFFSET                   = $0D13;
  GL_RED_SCALE                      = $0D14;
  GL_RED_BIAS                       = $0D15;
  GL_ZOOM_X                         = $0D16;
  GL_ZOOM_Y                         = $0D17;
  GL_GREEN_SCALE                    = $0D18;
  GL_GREEN_BIAS                     = $0D19;
  GL_BLUE_SCALE                     = $0D1A;
  GL_BLUE_BIAS                      = $0D1B;
  GL_ALPHA_SCALE                    = $0D1C;
  GL_ALPHA_BIAS                     = $0D1D;
  GL_DEPTH_SCALE                    = $0D1E;
  GL_DEPTH_BIAS                     = $0D1;
  GL_MAX_EVAL_ORDER                 = $0D30;
  GL_MAX_LIGHTS                     = $0D31;
  GL_MAX_CLIP_PLANES                = $0D32;
  GL_MAX_TEXTURE_SIZE               = $0D33;
  GL_MAX_PIXEL_MAP_TABLE            = $0D34;
  GL_MAX_ATTRIB_STACK_DEPTH         = $0D35;
  GL_MAX_MODELVIEW_STACK_DEPTH      = $0D36;
  GL_MAX_NAME_STACK_DEPTH           = $0D37;
  GL_MAX_PROJECTION_STACK_DEPTH     = $0D38;
  GL_MAX_TEXTURE_STACK_DEPTH        = $0D39;
  GL_MAX_VIEWPORT_DIMS              = $0D3A;
  GL_SUBPIXEL_BITS                  = $0D50;
  GL_INDEX_BITS                     = $0D51;
  GL_RED_BITS                       = $0D52;
  GL_GREEN_BITS                     = $0D53;
  GL_BLUE_BITS                      = $0D54;
  GL_ALPHA_BITS                     = $0D55;
  GL_DEPTH_BITS                     = $0D56;
  GL_STENCIL_BITS                   = $0D57;
  GL_ACCUM_RED_BITS                 = $0D58;
  GL_ACCUM_GREEN_BITS               = $0D59;
  GL_ACCUM_BLUE_BITS                = $0D5A;
  GL_ACCUM_ALPHA_BITS               = $0D5B;
  GL_NAME_STACK_DEPTH               = $0D70;
  GL_AUTO_NORMAL                    = $0D80;
  GL_MAP1_COLOR_4                   = $0D90;
  GL_MAP1_INDEX                     = $0D91;
  GL_MAP1_NORMAL                    = $0D92;
  GL_MAP1_TEXTURE_COORD_1           = $0D93;
  GL_MAP1_TEXTURE_COORD_2           = $0D94;
  GL_MAP1_TEXTURE_COORD_3           = $0D95;
  GL_MAP1_TEXTURE_COORD_4           = $0D96;
  GL_MAP1_VERTEX_3                  = $0D97;
  GL_MAP1_VERTEX_4                  = $0D98;
  GL_MAP2_COLOR_4                   = $0DB0;
  GL_MAP2_INDEX                     = $0DB1;
  GL_MAP2_NORMAL                    = $0DB2;
  GL_MAP2_TEXTURE_COORD_1           = $0DB3;
  GL_MAP2_TEXTURE_COORD_2           = $0DB4;
  GL_MAP2_TEXTURE_COORD_3           = $0DB5;
  GL_MAP2_TEXTURE_COORD_4           = $0DB6;
  GL_MAP2_VERTEX_3                  = $0DB7;
  GL_MAP2_VERTEX_4                  = $0DB8;
  GL_MAP1_GRID_DOMAIN               = $0DD0;
  GL_MAP1_GRID_SEGMENTS             = $0DD1;
  GL_MAP2_GRID_DOMAIN               = $0DD2;
  GL_MAP2_GRID_SEGMENTS             = $0DD3;
  GL_TEXTURE_1D                     = $0DE0;
  GL_TEXTURE_2D                     = $0DE1;
(*GL_VERTEX_ARRAY_EXT*)
(*GL_NORMAL_ARRAY_EXT*)
(*GL_COLOR_ARRAY_EXT*)
(*GL_INDEX_ARRAY_EXT*)
(*GL_TEXTURE_COORD_ARRAY_EXT*)
(*GL_EDGE_FLAG_ARRAY_EXT*)
(*GL_VERTEX_ARRAY_SIZE_EXT*)
(*GL_VERTEX_ARRAY_TYPE_EXT*)
(*GL_VERTEX_ARRAY_STRIDE_EXT*)
(*GL_VERTEX_ARRAY_COUNT_EXT*)
(*GL_NORMAL_ARRAY_TYPE_EXT*)
(*GL_NORMAL_ARRAY_STRIDE_EXT*)
(*GL_NORMAL_ARRAY_COUNT_EXT*)
(*GL_COLOR_ARRAY_SIZE_EXT*)
(*GL_COLOR_ARRAY_TYPE_EXT*)
(*GL_COLOR_ARRAY_STRIDE_EXT*)
(*GL_COLOR_ARRAY_COUNT_EXT*)
(*GL_INDEX_ARRAY_TYPE_EXT*)
(*GL_INDEX_ARRAY_STRIDE_EXT*)
(*GL_INDEX_ARRAY_COUNT_EXT*)
(*GL_TEXTURE_COORD_ARRAY_SIZE_EXT*)
(*GL_TEXTURE_COORD_ARRAY_TYPE_EXT*)
(*GL_TEXTURE_COORD_ARRAY_STRIDE_EXT*)
(*GL_TEXTURE_COORD_ARRAY_COUNT_EXT*)
(*GL_EDGE_FLAG_ARRAY_STRIDE_EXT*)
(*GL_EDGE_FLAG_ARRAY_COUNT_EXT*)

// GetTextureParameter
(*GL_TEXTURE_MAG_FILTER*)
(*GL_TEXTURE_MIN_FILTER*)
(*GL_TEXTURE_WRAP_S*)
(*GL_TEXTURE_WRAP_T*)
const
  GL_TEXTURE_WIDTH          = $1000;
  GL_TEXTURE_HEIGHT         = $1001;
  GL_TEXTURE_COMPONENTS     = $1003;
  GL_TEXTURE_BORDER_COLOR   = $1004;
  GL_TEXTURE_BORDER         = $1005;

// HintMode
const
  GL_DONT_CARE              = $1100;
  GL_FASTEST                = $1101;
  GL_NICEST                 = $1102;

// HintTarget
(*GL_PERSPECTIVE_CORRECTION_HINT*)
(*GL_POINT_SMOOTH_HINT*)
(*GL_LINE_SMOOTH_HINT*)
(*GL_POLYGON_SMOOTH_HINT*)
(*GL_FOG_HINT*)

// IndexPointerType
(*GL_SHORT*)
(*GL_INT*)
(*GL_FLOAT*)
(*GL_DOUBLE_EXT*)

// LightModelParameter
(*GL_LIGHT_MODEL_AMBIENT*)
(*GL_LIGHT_MODEL_LOCAL_VIEWER*)
(*GL_LIGHT_MODEL_TWO_SIDE*)

// LightName
const
  GL_LIGHT0                 = $4000;
  GL_LIGHT1                 = $4001;
  GL_LIGHT2                 = $4002;
  GL_LIGHT3                 = $4003;
  GL_LIGHT4                 = $4004;
  GL_LIGHT5                 = $4005;
  GL_LIGHT6                 = $4006;
  GL_LIGHT7                 = $4007;

// LightParameter
const
  GL_AMBIENT                = $1200;
  GL_DIFFUSE                = $1201;
  GL_SPECULAR               = $1202;
  GL_POSITION               = $1203;
  GL_SPOT_DIRECTION         = $1204;
  GL_SPOT_EXPONENT          = $1205;
  GL_SPOT_CUTOFF            = $1206;
  GL_CONSTANT_ATTENUATION   = $1207;
  GL_LINEAR_ATTENUATION     = $1208;
  GL_QUADRATIC_ATTENUATION  = $1209;

// ListMode
const
  GL_COMPILE                = $1300;
  GL_COMPILE_AND_EXECUTE    = $1301;

// ListNameType
const
  GL_BYTE                   = $1400;
  GL_UNSIGNED_BYTE          = $1401;
  GL_SHORT                  = $1402;
  GL_UNSIGNED_SHORT         = $1403;
  GL_INT                    = $1404;
  GL_UNSIGNED_INT           = $1405;
  GL_FLOAT                  = $1406;
  GL_2_BYTES                = $1407;
  GL_3_BYTES                = $1408;
  GL_4_BYTES                = $1409;
  GL_DOUBLE_EXT             = $140A;

// LogicOp
const
  GL_CLEAR                  = $1500;
  GL_AND                    = $1501;
  GL_AND_REVERSE            = $1502;
  GL_COPY                   = $1503;
  GL_AND_INVERTED           = $1504;
  GL_NOOP                   = $1505;
  GL_XOR                    = $1506;
  GL_OR                     = $1507;
  GL_NOR                    = $1508;
  GL_EQUIV                  = $1509;
  GL_INVERT                 = $150A;
  GL_OR_REVERSE             = $150B;
  GL_COPY_INVERTED          = $150C;
  GL_OR_INVERTED            = $150D;
  GL_NAND                   = $150E;
  GL_SET                    = $150;

// MapTarget
(*GL_MAP1_COLOR_4*)
(*GL_MAP1_INDEX*)
(*GL_MAP1_NORMAL*)
(*GL_MAP1_TEXTURE_COORD_1*)
(*GL_MAP1_TEXTURE_COORD_2*)
(*GL_MAP1_TEXTURE_COORD_3*)
(*GL_MAP1_TEXTURE_COORD_4*)
(*GL_MAP1_VERTEX_3*)
(*GL_MAP1_VERTEX_4*)
(*GL_MAP2_COLOR_4*)
(*GL_MAP2_INDEX*)
(*GL_MAP2_NORMAL*)
(*GL_MAP2_TEXTURE_COORD_1*)
(*GL_MAP2_TEXTURE_COORD_2*)
(*GL_MAP2_TEXTURE_COORD_3*)
(*GL_MAP2_TEXTURE_COORD_4*)
(*GL_MAP2_VERTEX_3*)
(*GL_MAP2_VERTEX_4*)

// MaterialFace
(*GL_FRONT*)
(*GL_BACK*)
(*GL_FRONT_AND_BACK*)

// MaterialParameter
const
  GL_EMISSION               = $1600;
  GL_SHININESS              = $1601;
  GL_AMBIENT_AND_DIFFUSE    = $1602;
  GL_COLOR_INDEXES          = $1603;
(*GL_AMBIENT*)
(*GL_DIFFUSE*)
(*GL_SPECULAR*)

// MatrixMode
const
  GL_MODELVIEW              = $1700;
  GL_PROJECTION             = $1701;
  GL_TEXTURE                = $1702;

// MeshMode1
(*GL_POINT*)
(*GL_LINE*)

// MeshMode2
(*GL_POINT*)
(*GL_LINE*)
(*GL_FILL*)

// NormalPointerType
(*GL_BYTE*)
(*GL_SHORT*)
(*GL_INT*)
(*GL_FLOAT*)
(*GL_DOUBLE_EXT*)

// PixelCopyType*)
const
  GL_COLOR                  = $1800;
  GL_DEPTH                  = $1801;
  GL_STENCIL                = $1802;

// PixelFormat
const
  GL_COLOR_INDEX            = $1900;
  GL_STENCIL_INDEX          = $1901;
  GL_DEPTH_COMPONENT        = $1902;
  GL_RED                    = $1903;
  GL_GREEN                  = $1904;
  GL_BLUE                   = $1905;
  GL_ALPHA                  = $1906;
  GL_RGB                    = $1907;
  GL_RGBA                   = $1908;
  GL_LUMINANCE              = $1909;
  GL_LUMINANCE_ALPHA        = $190A;

// PixelMap
(*GL_PIXEL_MAP_I_TO_I*)
(*GL_PIXEL_MAP_S_TO_S*)
(*GL_PIXEL_MAP_I_TO_R*)
(*GL_PIXEL_MAP_I_TO_G*)
(*GL_PIXEL_MAP_I_TO_B*)
(*GL_PIXEL_MAP_I_TO_A*)
(*GL_PIXEL_MAP_R_TO_R*)
(*GL_PIXEL_MAP_G_TO_G*)
(*GL_PIXEL_MAP_B_TO_B*)
(*GL_PIXEL_MAP_A_TO_A*)

// PixelStore
(*GL_UNPACK_SWAP_BYTES*)
(*GL_UNPACK_LSB_FIRST*)
(*GL_UNPACK_ROW_LENGTH*)
(*GL_UNPACK_SKIP_ROWS*)
(*GL_UNPACK_SKIP_PIXELS*)
(*GL_UNPACK_ALIGNMENT*)
(*GL_PACK_SWAP_BYTES*)
(*GL_PACK_LSB_FIRST*)
(*GL_PACK_ROW_LENGTH*)
(*GL_PACK_SKIP_ROWS*)
(*GL_PACK_SKIP_PIXELS*)
(*GL_PACK_ALIGNMENT*)

// PixelTransfer
(*GL_MAP_COLOR*)
(*GL_MAP_STENCIL*)
(*GL_INDEX_SHIFT*)
(*GL_INDEX_OFFSET*)
(*GL_RED_SCALE*)
(*GL_RED_BIAS*)
(*GL_GREEN_SCALE*)
(*GL_GREEN_BIAS*)
(*GL_BLUE_SCALE*)
(*GL_BLUE_BIAS*)
(*GL_ALPHA_SCALE*)
(*GL_ALPHA_BIAS*)
(*GL_DEPTH_SCALE*)
(*GL_DEPTH_BIAS*)

// PixelType
const
  GL_BITMAP                 = $1A00;
(*GL_BYTE*)
(*GL_UNSIGNED_BYTE*)
(*GL_SHORT*)
(*GL_UNSIGNED_SHORT*)
(*GL_INT*)
(*GL_UNSIGNED_INT*)
(*GL_FLOAT*)

// PolygonMode
const
  GL_POINT                  = $1B00;
  GL_LINE                   = $1B01;
  GL_FILL                   = $1B02;

// ReadBufferMode
(*GL_FRONT_LEFT*)
(*GL_FRONT_RIGHT*)
(*GL_BACK_LEFT*)
(*GL_BACK_RIGHT*)
(*GL_FRONT*)
(*GL_BACK*)
(*GL_LEFT*)
(*GL_RIGHT*)
(*GL_AUX0*)
(*GL_AUX1*)
(*GL_AUX2*)
(*GL_AUX3*)

// RenderingMode
const
  GL_RENDER                 = $1C00;
  GL_FEEDBACK               = $1C01;
  GL_SELECT                 = $1C02;

// ShadingModel
const
  GL_FLAT                   = $1D00;
  GL_SMOOTH                 = $1D01;

// StencilFunction
(*GL_NEVER*)
(*GL_LESS*)
(*GL_EQUAL*)
(*GL_LEQUAL*)
(*GL_GREATER*)
(*GL_NOTEQUAL*)
(*GL_GEQUAL*)
(*GL_ALWAYS*)

// StencilOp
(*GL_ZERO*)
const
  GL_KEEP                   = $1E00;
  GL_REPLACE                = $1E01;
  GL_INCR                   = $1E02;
  GL_DECR                   = $1E03;
(*GL_INVERT*)

// StringName
const
  GL_VENDOR                 = $1F00;
  GL_RENDERER               = $1F01;
  GL_VERSION                = $1F02;
  GL_EXTENSIONS             = $1F03;

// TextureCoordName
const
  GL_S                      = $2000;
  GL_T                      = $2001;
  GL_R                      = $2002;
  GL_Q                      = $2003;

// TexCoordPointerType
(*GL_SHORT*)
(*GL_INT*)
(*GL_FLOAT*)
(*GL_DOUBLE_EXT*)

// TextureEnvMode
const
  GL_MODULATE               = $2100;
  GL_DECAL                  = $2101;
(*GL_BLEND*)

// TextureEnvParameter
const
  GL_TEXTURE_ENV_MODE       = $2200;
  GL_TEXTURE_ENV_COLOR      = $2201;

// TextureEnvTarget
const
  GL_TEXTURE_ENV            = $2300;

// TextureGenMode
const
  GL_EYE_LINEAR             = $2400;
  GL_OBJECT_LINEAR          = $2401;
  GL_SPHERE_MAP             = $2402;

// TextureGenParameter
const
  GL_TEXTURE_GEN_MODE       = $2500;
  GL_OBJECT_PLANE           = $2501;
  GL_EYE_PLANE              = $2502;

// TextureMagFilter
const
  GL_NEAREST                = $2600;
  GL_LINEAR                 = $2601;

// TextureMinFilter
(*GL_NEAREST*)
(*GL_LINEAR*)
const
  GL_NEAREST_MIPMAP_NEAREST = $2700;
  GL_LINEAR_MIPMAP_NEAREST  = $2701;
  GL_NEAREST_MIPMAP_LINEAR  = $2702;
  GL_LINEAR_MIPMAP_LINEAR   = $2703;

// TextureParameterName
const
  GL_TEXTURE_MAG_FILTER     = $2800;
  GL_TEXTURE_MIN_FILTER     = $2801;
  GL_TEXTURE_WRAP_S         = $2802;
  GL_TEXTURE_WRAP_T         = $2803;
(*GL_TEXTURE_BORDER_COLOR*)

// TextureTarget
(*GL_TEXTURE_1D*)
(*GL_TEXTURE_2D*)

// TextureWrapMode
const
  GL_CLAMP                  = $2900;
  GL_REPEAT                 = $2901;

// VertexPointerType
(*GL_SHORT*)
(*GL_INT*)
(*GL_FLOAT*)
(*GL_DOUBLE_EXT*)

// Extensions
const
  GL_EXT_vertex_array       = 1;
  GL_WIN_swap_hint          = 1;

// EXT_vertex_array
const
  GL_VERTEX_ARRAY_EXT               = $8074;
  GL_NORMAL_ARRAY_EXT               = $8075;
  GL_COLOR_ARRAY_EXT                = $8076;
  GL_INDEX_ARRAY_EXT                = $8077;
  GL_TEXTURE_COORD_ARRAY_EXT        = $8078;
  GL_EDGE_FLAG_ARRAY_EXT            = $8079;
  GL_VERTEX_ARRAY_SIZE_EXT          = $807A;
  GL_VERTEX_ARRAY_TYPE_EXT          = $807B;
  GL_VERTEX_ARRAY_STRIDE_EXT        = $807C;
  GL_VERTEX_ARRAY_COUNT_EXT         = $807D;
  GL_NORMAL_ARRAY_TYPE_EXT          = $807E;
  GL_NORMAL_ARRAY_STRIDE_EXT        = $807;
  GL_NORMAL_ARRAY_COUNT_EXT         = $8080;
  GL_COLOR_ARRAY_SIZE_EXT           = $8081;
  GL_COLOR_ARRAY_TYPE_EXT           = $8082;
  GL_COLOR_ARRAY_STRIDE_EXT         = $8083;
  GL_COLOR_ARRAY_COUNT_EXT          = $8084;
  GL_INDEX_ARRAY_TYPE_EXT           = $8085;
  GL_INDEX_ARRAY_STRIDE_EXT         = $8086;
  GL_INDEX_ARRAY_COUNT_EXT          = $8087;
  GL_TEXTURE_COORD_ARRAY_SIZE_EXT   = $8088;
  GL_TEXTURE_COORD_ARRAY_TYPE_EXT   = $8089;
  GL_TEXTURE_COORD_ARRAY_STRIDE_EXT = $808A;
  GL_TEXTURE_COORD_ARRAY_COUNT_EXT  = $808B;
  GL_EDGE_FLAG_ARRAY_STRIDE_EXT     = $808C;
  GL_EDGE_FLAG_ARRAY_COUNT_EXT      = $808D;
  GL_VERTEX_ARRAY_POINTER_EXT       = $808E;
  GL_NORMAL_ARRAY_POINTER_EXT       = $808;
  GL_COLOR_ARRAY_POINTER_EXT        = $8090;
  GL_INDEX_ARRAY_POINTER_EXT        = $8091;
  GL_TEXTURE_COORD_ARRAY_POINTER_EXT= $8092;
  GL_EDGE_FLAG_ARRAY_POINTER_EXT    = $8093;


//*************************************************************

type
  TViewPortArray  = Array[0..3] of GLint;
  TMatrixDblArray = Array[0..15] of GLdouble;
  TMatrixFltArray = Array[0..15] of GLfloat;
  TCoordArray     = Array[0..2] of GLdouble;
  T4PointerArray  = Array[0..3] of Pointer;
  T4FloatArray    = Array[0..3] of GLfloat;


var
 hgllib,hglulib:integer;
 
 glBegin:Procedure (mode: GLenum);stdcall;
 glBindTexture: Procedure (target: GLenum; texture:GLuint); stdcall;
 glCallList:Procedure (list: GLuint);stdcall;
 glClear:Procedure (mask: GLbitfield);stdcall;
 glClearColor:Procedure (red: GLclampf; green: GLclampf; blue: GLclampf; alpha: GLclampf);stdcall;
 glColor3f:Procedure (red: GLfloat; green: GLfloat; blue: GLfloat);stdcall;
 glColor3ub:Procedure (red: GLubyte; green: GLubyte; blue: GLubyte);stdcall;
 glCullFace:Procedure (mode: GLenum);stdcall;
 glDeleteLists:Procedure (list: GLuint; range: GLsizei);stdcall;
 glDeleteTextures:Procedure(n:GLsizei; var textures:GLuint); stdcall;
 glDepthRange:Procedure (zNear: GLclampd; zFar: GLclampd);stdcall;
 glDisable:Procedure (cap: GLenum);stdcall;
 glEnable:Procedure (cap: GLenum);stdcall;
 glend: procedure; stdcall;
 glEndList: procedure; stdcall;
 glFlush: Procedure;stdcall;

 glFrontFace:Procedure (mode: GLenum);stdcall;
 glGenLists: Function (range: GLsizei): GLuint; stdcall;
 glGenTextures: Procedure (n:GLsizei; var textures:GLuint); stdcall;

 glGetDoublev:Procedure (pname: GLenum; params: PGLdouble);stdcall;
 glGetError: Function : GLenum; stdcall;
 glGetIntegerv:Procedure (pname: GLenum; params: PGLint);stdcall;
 glHint:Procedure (target: GLenum; mode: GLenum);stdcall;
 glInitNames: Procedure;stdcall;
 glLoadIdentity: Procedure; stdcall;
 glLoadName:Procedure (name: GLuint);stdcall;
 glMatrixMode:Procedure (mode: GLenum);stdcall;
 glNewList:Procedure (list: GLuint; mode: GLenum);stdcall;
 glOrtho:Procedure (left: GLdouble; right: GLdouble; bottom: GLdouble; top: GLdouble; zNear: GLdouble; zFar: GLdouble);stdcall;
 glPixelStorei:Procedure (pname: GLenum; param: GLint);stdcall;
 glPointSize:Procedure (size: GLfloat);stdcall;
 glPolygonMode:Procedure (face: GLenum; mode: GLenum);stdcall;
 glPushName:Procedure (name: GLuint);stdcall;
 glRenderMode:Function (mode: GLenum): GLint;stdcall;
 glRotated:Procedure (angle: GLdouble; x: GLdouble; y: GLdouble; z: GLdouble);stdcall;
 glScaled:Procedure (x: GLdouble; y: GLdouble; z: GLdouble);stdcall;
 glSelectBuffer:Procedure (size: GLsizei; buffer: PGLuint);stdcall;
 glShadeModel:Procedure (mode: GLenum);stdcall;
 glTexCoord2f:Procedure (s: GLfloat; t: GLfloat);stdcall;
 glTexEnvf:Procedure (target: GLenum; pname: GLenum; param: GLfloat);stdcall;
 glTexGeniv:Procedure (coord: GLenum; pname: GLenum; params: PGLint);stdcall;
 glTexImage2D:Procedure (target: GLenum; level: GLint; components: GLint; width: GLsizei; height: GLsizei; border: GLint; format: GLenum; atype: GLenum; const pixels);stdcall;
 glTexParameterf:Procedure (target: GLenum; pname: GLenum; param: GLfloat);stdcall;
 glTranslated:Procedure (x: GLdouble; y: GLdouble; z: GLdouble);stdcall;
 glVertex3d:Procedure (x: GLdouble; y: GLdouble; z: GLdouble);stdcall;
 glVertex3f:Procedure (x: GLfloat; y: GLfloat; z: GLfloat);stdcall;
 glViewport:Procedure (x: GLint; y: GLint; width: GLsizei; height: GLsizei);stdcall;

wglCreateContext: function (DC: HDC): HGLRC; stdcall;
wglDeleteContext: function (p1: HGLRC): BOOL; stdcall;
wglGetCurrentContext: function : HGLRC; stdcall;
wglMakeCurrent: function (DC: HDC; p2: HGLRC): BOOL; stdcall;
wglGetProcAddress: function (ProcName: PChar): Pointer;  stdcall;



gluPerspective: Procedure (fovy: GLdouble; aspect: GLdouble; zNear: GLdouble; zFar: GLdouble);
                          stdcall;
gluPickMatrix: Procedure (x: GLdouble; y: GLdouble; width: GLdouble; height: GLdouble; viewport: TViewPortArray);
                          stdcall;
gluLookAt: Procedure (eyex: GLdouble; eyey: GLdouble; eyez: GLdouble; centerx: GLdouble; centery: GLdouble;
                    centerz: GLdouble; upx: GLdouble; upy: GLdouble; upz: GLdouble);
                          stdcall;
gluProject: Function (objx: GLdouble; objy: GLdouble; objz: GLdouble; const modelMatrix: TMatrixDblArray;
                    const projMatrix: TMatrixDblArray; const viewport: TViewPortArray;
                    var winx: GLdouble; var winy: GLdouble; var winz: GLdouble): INT;
                          stdcall;
gluUnProject: Function (winx: GLdouble; winy: GLdouble; winz: GLdouble; const modelMatrix: TMatrixDblArray;
                      const projMatrix: TMatrixDblArray; const viewport: TViewPortArray; var objx: GLdouble;
                      var objy: GLdouble; var objz: GLdouble): INT;
                          stdcall;


Function InitOpenGL:boolean;

implementation

Function InitOpenGL:boolean;
var gllib,glulib:integer;
    res:boolean;

Function LoadGLProc(const name:string):pointer;
begin
 if not res then exit;
 result:=GetProcAddress(gllib,Pchar(name));
 res:=res and (result<>nil);
 if result=nil then PanMessage(mt_warning,'Couldn''t find function '+name+' in OpenGL32.DLL');
end;

Function LoadGLUProc(const name:string):pointer;
begin
 if not res then exit;
 result:=GetProcAddress(glulib,Pchar(name));
 res:=res and (result<>nil);
 if result=nil then PanMessage(mt_warning,'Couldn''t find function '+name+' in Glu32.DLL');
end;

begin
 result:=true;
 if hgllib<>0 then exit;

 result:=false;

 gllib:=LoadLibrary('Opengl32.dll');
 if gllib=0 then begin PanMessage(mt_warning,'Couldn''t load OpenGL32.DLL'); exit; end;

 res:=true;

 glbegin:=LoadGLProc('glBegin');
 glBindTexture:=LoadGLProc('glBindTexture');
 glCallList:=LoadGLProc('glCallList');
 glClear:=LoadGLProc('glClear');
 glClearColor:=LoadGLProc('glClearColor');
 glColor3f:=LoadGLProc('glColor3f');
 glColor3ub:=LoadGLProc('glColor3ub');
 glCullFace:=LoadGLProc('glCullFace');
 glDeleteLists:=LoadGLProc('glDeleteLists');
 glDeleteTextures:=LoadGLProc('glDeleteTextures');
 glDepthRange:=LoadGLProc('glDepthRange');
 glDisable:=LoadGLProc('glDisable');
 glEnable:=LoadGLProc('glEnable');
 glend:=LoadGLProc('glEnd');
 glEndList:=LoadGLProc('glEndList');
 glFlush:=LoadGLProc('glFlush');

 glFrontFace:=LoadGLProc('glFrontFace');
 glGenLists:=LoadGLProc('glGenLists');
 glGenTextures:=LoadGLProc('glGenTextures');

 glGetDoublev:=LoadGLProc('glGetDoublev');
 glGetError:=LoadGLProc('glGetError');
 glGetIntegerv:=LoadGLProc('glGetIntegerv');
 glHint:=LoadGLProc('glHint');
 glInitNames:=LoadGLProc('glInitNames');
 glLoadIdentity:=LoadGLProc('glLoadIdentity');
 glLoadName:=LoadGLProc('glLoadName');
 glMatrixMode:=LoadGLProc('glMatrixMode');
 glNewList:=LoadGLProc('glNewList');
 glOrtho:=LoadGLProc('glOrtho');
 glPixelStorei:=LoadGLProc('glPixelStorei');
 glPointSize:=LoadGLProc('glPointSize');
 glPolygonMode:=LoadGLProc('glPolygonMode');
 glPushName:=LoadGLProc('glPushName');
 glRenderMode:=LoadGLProc('glRenderMode');
 glRotated:=LoadGLProc('glRotated');
 glScaled:=LoadGLProc('glScaled');
 glSelectBuffer:=LoadGLProc('glSelectBuffer');
 glShadeModel:=LoadGLProc('glShadeModel');
 glTexCoord2f:=LoadGLProc('glTexCoord2f');
 glTexEnvf:=LoadGLProc('glTexEnvf');
 glTexGeniv:=LoadGLProc('glTexGeniv');
 glTexImage2D:=LoadGLProc('glTexImage2D');
 glTexParameterf:=LoadGLProc('glTexParameterf');
 glTranslated:=LoadGLProc('glTranslated');
 glVertex3d:=LoadGLProc('glVertex3d');
 glVertex3f:=LoadGLProc('glVertex3f');
 glViewport:=LoadGLProc('glViewport');

 wglCreateContext:=LoadGLProc('wglCreateContext');
 wglDeleteContext:=LoadGLProc('wglDeleteContext');
 wglGetCurrentContext:=LoadGLProc('wglGetCurrentContext');
 wglMakeCurrent:=LoadGLProc('wglMakeCurrent');
 wglGetProcAddress:=LoadGLProc('wglGetProcAddress');

 if not res then
 begin
  FreeLibrary(gllib);
  exit;
 end;

 glulib:=LoadLibrary('Glu32.dll');
 if glulib=0 then
 begin
  PanMessage(mt_warning,'Couldn''t load Glu32.DLL');
  FreeLibrary(gllib);
  exit;
 end;

gluPerspective:=LoadGLUProc('gluPerspective');
gluPickMatrix:=LoadGLUProc('gluPickMatrix');
gluLookAt:=LoadGLUProc('gluLookAt');
gluProject:=LoadGLUProc('gluProject');
gluUnProject:=LoadGLUProc('gluUnProject');

 if not res then
 begin
  FreeLibrary(gllib);
  FreeLibrary(glulib);
  exit;
 end;

 result:=true;

 hgllib:=gllib;
 hglulib:=glulib;
end;

end.
