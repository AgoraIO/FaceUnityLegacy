//////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) Microsoft Corporation.  All Rights Reserved.
//
//  File:       d3dx9mesh.h
//  Content:    D3DX mesh types and functions
//
//////////////////////////////////////////////////////////////////////////////

#include "d3dx9.h"

#ifndef __D3DX9MESH_H__
#define __D3DX9MESH_H__

#include "dxfile.h"     // defines LPDIRECTXFILEDATA

// {4F5621A3-7F25-46dc-8239-820B823795CB}
DEFINE_GUID(IID_ID3DXBaseMesh, 
0x4f5621a3, 0x7f25, 0x46dc, 0x82, 0x39, 0x82, 0xb, 0x82, 0x37, 0x95, 0xcb);

// {29E3EB8D-4DD6-4524-B1A2-1EF0581E778D}
DEFINE_GUID(IID_ID3DXMesh, 
0x29e3eb8d, 0x4dd6, 0x4524, 0xb1, 0xa2, 0x1e, 0xf0, 0x58, 0x1e, 0x77, 0x8d);

// {1da4801f-a26e-4623-bd5471ff57f4bd02}
DEFINE_GUID(IID_ID3DXPMesh, 
0x1da4801f, 0xa26e, 0x4623, 0xbd, 0x54, 0x71, 0xff, 0x57, 0xf4, 0xbd, 0x2);

// {1C4E77C5-8391-4951-A019-D4C5A9539EEC}
DEFINE_GUID(IID_ID3DXSPMesh, 
0x1c4e77c5, 0x8391, 0x4951, 0xa0, 0x19, 0xd4, 0xc5, 0xa9, 0x53, 0x9e, 0xec);

// {0E7DBBF3-421A-4dd8-B738-A5DAC3A48767}
DEFINE_GUID(IID_ID3DXSkinInfo, 
0xe7dbbf3, 0x421a, 0x4dd8, 0xb7, 0x38, 0xa5, 0xda, 0xc3, 0xa4, 0x87, 0x67);

// {0AD3E8BC-290D-4dc7-91AB-73A82755B13E}
DEFINE_GUID(IID_ID3DXPatchMesh, 
0xad3e8bc, 0x290d, 0x4dc7, 0x91, 0xab, 0x73, 0xa8, 0x27, 0x55, 0xb1, 0x3e);

//patch mesh can be quads or tris
typedef enum _D3DXPATCHMESHTYPE {
    D3DXPATCHMESH_RECT   = 0x001,
    D3DXPATCHMESH_TRI    = 0x002,
    D3DXPATCHMESH_NPATCH = 0x003,

    D3DXPATCHMESH_FORCE_DWORD    = 0x7fffffff, /* force 32-bit size enum */
} D3DXPATCHMESHTYPE;

// Mesh options - lower 3 bytes only, upper byte used by _D3DXMESHOPT option flags
enum _D3DXMESH {
    D3DXMESH_32BIT                  = 0x001, // If set, then use 32 bit indices, if not set use 16 bit indices.
    D3DXMESH_DONOTCLIP              = 0x002, // Use D3DUSAGE_DONOTCLIP for VB & IB.
    D3DXMESH_POINTS                 = 0x004, // Use D3DUSAGE_POINTS for VB & IB. 
    D3DXMESH_RTPATCHES              = 0x008, // Use D3DUSAGE_RTPATCHES for VB & IB. 
    D3DXMESH_NPATCHES               = 0x4000,// Use D3DUSAGE_NPATCHES for VB & IB. 
    D3DXMESH_VB_SYSTEMMEM           = 0x010, // Use D3DPOOL_SYSTEMMEM for VB. Overrides D3DXMESH_MANAGEDVERTEXBUFFER
    D3DXMESH_VB_MANAGED             = 0x020, // Use D3DPOOL_MANAGED for VB. 
    D3DXMESH_VB_WRITEONLY           = 0x040, // Use D3DUSAGE_WRITEONLY for VB.
    D3DXMESH_VB_DYNAMIC             = 0x080, // Use D3DUSAGE_DYNAMIC for VB.
    D3DXMESH_VB_SOFTWAREPROCESSING = 0x8000, // Use D3DUSAGE_SOFTWAREPROCESSING for VB.
    D3DXMESH_IB_SYSTEMMEM           = 0x100, // Use D3DPOOL_SYSTEMMEM for IB. Overrides D3DXMESH_MANAGEDINDEXBUFFER
    D3DXMESH_IB_MANAGED             = 0x200, // Use D3DPOOL_MANAGED for IB.
    D3DXMESH_IB_WRITEONLY           = 0x400, // Use D3DUSAGE_WRITEONLY for IB.
    D3DXMESH_IB_DYNAMIC             = 0x800, // Use D3DUSAGE_DYNAMIC for IB.
    D3DXMESH_IB_SOFTWAREPROCESSING= 0x10000, // Use D3DUSAGE_SOFTWAREPROCESSING for IB.

    D3DXMESH_VB_SHARE               = 0x1000, // Valid for Clone* calls only, forces cloned mesh/pmesh to share vertex buffer

    D3DXMESH_USEHWONLY              = 0x2000, // Valid for ID3DXSkinInfo::ConvertToBlendedMesh

    // Helper options
    D3DXMESH_SYSTEMMEM              = 0x110, // D3DXMESH_VB_SYSTEMMEM | D3DXMESH_IB_SYSTEMMEM
    D3DXMESH_MANAGED                = 0x220, // D3DXMESH_VB_MANAGED | D3DXMESH_IB_MANAGED
    D3DXMESH_WRITEONLY              = 0x440, // D3DXMESH_VB_WRITEONLY | D3DXMESH_IB_WRITEONLY
    D3DXMESH_DYNAMIC                = 0x880, // D3DXMESH_VB_DYNAMIC | D3DXMESH_IB_DYNAMIC
    D3DXMESH_SOFTWAREPROCESSING   = 0x18000, // D3DXMESH_VB_SOFTWAREPROCESSING | D3DXMESH_IB_SOFTWAREPROCESSING

};

//patch mesh options
enum _D3DXPATCHMESH {
    D3DXPATCHMESH_DEFAULT = 000,
};
// option field values for specifying min value in D3DXGeneratePMesh and D3DXSimplifyMesh
enum _D3DXMESHSIMP
{
    D3DXMESHSIMP_VERTEX   = 0x1,
    D3DXMESHSIMP_FACE     = 0x2,

};

enum _MAX_FVF_DECL_SIZE
{
    MAX_FVF_DECL_SIZE = MAXD3DDECLLENGTH + 1 // +1 for END
};

typedef struct ID3DXBaseMesh *LPD3DXBASEMESH;
typedef struct ID3DXMesh *LPD3DXMESH;
typedef struct ID3DXPMesh *LPD3DXPMESH;
typedef struct ID3DXSPMesh *LPD3DXSPMESH;
typedef struct ID3DXSkinInfo *LPD3DXSKININFO;
typedef struct ID3DXPatchMesh *LPD3DXPATCHMESH;

typedef struct _D3DXATTRIBUTERANGE
{
    DWORD AttribId;
    DWORD FaceStart;
    DWORD FaceCount;
    DWORD VertexStart;
    DWORD VertexCount;
} D3DXATTRIBUTERANGE;

typedef D3DXATTRIBUTERANGE* LPD3DXATTRIBUTERANGE;

typedef struct _D3DXMATERIAL
{
    D3DMATERIAL9  MatD3D;
    LPSTR         pTextureFilename;
} D3DXMATERIAL;
typedef D3DXMATERIAL *LPD3DXMATERIAL;

typedef enum _D3DXEFFECTDEFAULTTYPE
{
    D3DXEDT_STRING = 0x1,       // pValue points to a null terminated ASCII string 
    D3DXEDT_FLOATS = 0x2,       // pValue points to an array of floats - number of floats is NumBytes / sizeof(float)
    D3DXEDT_DWORD  = 0x3,       // pValue points to a DWORD

    D3DXEDT_FORCEDWORD = 0x7fffffff
} D3DXEFFECTDEFAULTTYPE;

typedef struct _D3DXEFFECTDEFAULT
{
    LPSTR                 pParamName;
    D3DXEFFECTDEFAULTTYPE Type;           // type of the data pointed to by pValue
    DWORD                 NumBytes;       // size in bytes of the data pointed to by pValue
    LPVOID                pValue;         // data for the default of the effect
} D3DXEFFECTDEFAULT, *LPD3DXEFFECTDEFAULT;

typedef struct _D3DXEFFECTINSTANCE
{
    LPSTR               pEffectFilename;
    DWORD               NumDefaults;
    LPD3DXEFFECTDEFAULT pDefaults;
} D3DXEFFECTINSTANCE, *LPD3DXEFFECTINSTANCE;

typedef struct _D3DXATTRIBUTEWEIGHTS
{
    FLOAT Position;
    FLOAT Boundary;
    FLOAT Normal;
    FLOAT Diffuse;
    FLOAT Specular;
    FLOAT Texcoord[8];
    FLOAT Tangent;
    FLOAT Binormal;
} D3DXATTRIBUTEWEIGHTS, *LPD3DXATTRIBUTEWEIGHTS;

enum _D3DXWELDEPSILONSFLAGS
{
    D3DXWELDEPSILONS_WELDALL             = 0x1,  // weld all vertices marked by adjacency as being overlapping

    D3DXWELDEPSILONS_WELDPARTIALMATCHES  = 0x2,  // if a given vertex component is within epsilon, modify partial matched 
                                                    // vertices so that both components identical AND if all components "equal"
                                                    // remove one of the vertices
    D3DXWELDEPSILONS_DONOTREMOVEVERTICES = 0x4,  // instructs weld to only allow modifications to vertices and not removal
                                                    // ONLY valid if D3DXWELDEPSILONS_WELDPARTIALMATCHES is set
                                                    // useful to modify vertices to be equal, but not allow vertices to be removed

    D3DXWELDEPSILONS_DONOTSPLIT          = 0x8,  // instructs weld to specify the D3DXMESHOPT_DONOTSPLIT flag when doing an Optimize(ATTR_SORT)
                                                    // if this flag is not set, all vertices that are in separate attribute groups
                                                    // will remain split and not welded.  Setting this flag can slow down software vertex processing

};

typedef struct _D3DXWELDEPSILONS
{
    FLOAT Position;                 // NOTE: This does NOT replace the epsilon in GenerateAdjacency
                                            // in general, it should be the same value or greater than the one passed to GeneratedAdjacency
    FLOAT BlendWeights;
    FLOAT Normal;
    FLOAT PSize;
    FLOAT Specular;
    FLOAT Diffuse;
    FLOAT Texcoord[8];
    FLOAT Tangent;
    FLOAT Binormal;
    FLOAT TessFactor;
} D3DXWELDEPSILONS;

typedef D3DXWELDEPSILONS* LPD3DXWELDEPSILONS;


#undef INTERFACE
#define INTERFACE ID3DXBaseMesh

DECLARE_INTERFACE_(ID3DXBaseMesh, IUnknown)
{
    // IUnknown
    STDMETHOD(QueryInterface)(THIS_ REFIID iid, LPVOID *ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;

    // ID3DXBaseMesh
    STDMETHOD(DrawSubset)(THIS_ DWORD AttribId) PURE;
    STDMETHOD_(DWORD, GetNumFaces)(THIS) PURE;
    STDMETHOD_(DWORD, GetNumVertices)(THIS) PURE;
    STDMETHOD_(DWORD, GetFVF)(THIS) PURE;
    STDMETHOD(GetDeclaration)(THIS_ D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]) PURE;
    STDMETHOD_(DWORD, GetNumBytesPerVertex)(THIS) PURE;
    STDMETHOD_(DWORD, GetOptions)(THIS) PURE;
    STDMETHOD(GetDevice)(THIS_ LPDIRECT3DDEVICE9* ppDevice) PURE;
    STDMETHOD(CloneMeshFVF)(THIS_ DWORD Options, 
                DWORD FVF, LPDIRECT3DDEVICE9 pD3DDevice, LPD3DXMESH* ppCloneMesh) PURE;
    STDMETHOD(CloneMesh)(THIS_ DWORD Options, 
                CONST D3DVERTEXELEMENT9 *pDeclaration, LPDIRECT3DDEVICE9 pD3DDevice, LPD3DXMESH* ppCloneMesh) PURE;
    STDMETHOD(GetVertexBuffer)(THIS_ LPDIRECT3DVERTEXBUFFER9* ppVB) PURE;
    STDMETHOD(GetIndexBuffer)(THIS_ LPDIRECT3DINDEXBUFFER9* ppIB) PURE;
    STDMETHOD(LockVertexBuffer)(THIS_ DWORD Flags, LPVOID *ppData) PURE;
    STDMETHOD(UnlockVertexBuffer)(THIS) PURE;
    STDMETHOD(LockIndexBuffer)(THIS_ DWORD Flags, LPVOID *ppData) PURE;
    STDMETHOD(UnlockIndexBuffer)(THIS) PURE;
    STDMETHOD(GetAttributeTable)(
                THIS_ D3DXATTRIBUTERANGE *pAttribTable, DWORD* pAttribTableSize) PURE;

    STDMETHOD(ConvertPointRepsToAdjacency)(THIS_ CONST DWORD* pPRep, DWORD* pAdjacency) PURE;
    STDMETHOD(ConvertAdjacencyToPointReps)(THIS_ CONST DWORD* pAdjacency, DWORD* pPRep) PURE;
    STDMETHOD(GenerateAdjacency)(THIS_ FLOAT Epsilon, DWORD* pAdjacency) PURE;

    STDMETHOD(UpdateSemantics)(THIS_ D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]) PURE;
};


#undef INTERFACE
#define INTERFACE ID3DXMesh

DECLARE_INTERFACE_(ID3DXMesh, ID3DXBaseMesh)
{
    // IUnknown
    STDMETHOD(QueryInterface)(THIS_ REFIID iid, LPVOID *ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;

    // ID3DXBaseMesh
    STDMETHOD(DrawSubset)(THIS_ DWORD AttribId) PURE;
    STDMETHOD_(DWORD, GetNumFaces)(THIS) PURE;
    STDMETHOD_(DWORD, GetNumVertices)(THIS) PURE;
    STDMETHOD_(DWORD, GetFVF)(THIS) PURE;
    STDMETHOD(GetDeclaration)(THIS_ D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]) PURE;
    STDMETHOD_(DWORD, GetNumBytesPerVertex)(THIS) PURE;
    STDMETHOD_(DWORD, GetOptions)(THIS) PURE;
    STDMETHOD(GetDevice)(THIS_ LPDIRECT3DDEVICE9* ppDevice) PURE;
    STDMETHOD(CloneMeshFVF)(THIS_ DWORD Options, 
                DWORD FVF, LPDIRECT3DDEVICE9 pD3DDevice, LPD3DXMESH* ppCloneMesh) PURE;
    STDMETHOD(CloneMesh)(THIS_ DWORD Options, 
                CONST D3DVERTEXELEMENT9 *pDeclaration, LPDIRECT3DDEVICE9 pD3DDevice, LPD3DXMESH* ppCloneMesh) PURE;
    STDMETHOD(GetVertexBuffer)(THIS_ LPDIRECT3DVERTEXBUFFER9* ppVB) PURE;
    STDMETHOD(GetIndexBuffer)(THIS_ LPDIRECT3DINDEXBUFFER9* ppIB) PURE;
    STDMETHOD(LockVertexBuffer)(THIS_ DWORD Flags, LPVOID *ppData) PURE;
    STDMETHOD(UnlockVertexBuffer)(THIS) PURE;
    STDMETHOD(LockIndexBuffer)(THIS_ DWORD Flags, LPVOID *ppData) PURE;
    STDMETHOD(UnlockIndexBuffer)(THIS) PURE;
    STDMETHOD(GetAttributeTable)(
                THIS_ D3DXATTRIBUTERANGE *pAttribTable, DWORD* pAttribTableSize) PURE;

    STDMETHOD(ConvertPointRepsToAdjacency)(THIS_ CONST DWORD* pPRep, DWORD* pAdjacency) PURE;
    STDMETHOD(ConvertAdjacencyToPointReps)(THIS_ CONST DWORD* pAdjacency, DWORD* pPRep) PURE;
    STDMETHOD(GenerateAdjacency)(THIS_ FLOAT Epsilon, DWORD* pAdjacency) PURE;

    STDMETHOD(UpdateSemantics)(THIS_ D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]) PURE;

    // ID3DXMesh
    STDMETHOD(LockAttributeBuffer)(THIS_ DWORD Flags, DWORD** ppData) PURE;
    STDMETHOD(UnlockAttributeBuffer)(THIS) PURE;
    STDMETHOD(Optimize)(THIS_ DWORD Flags, CONST DWORD* pAdjacencyIn, DWORD* pAdjacencyOut, 
                     DWORD* pFaceRemap, LPD3DXBUFFER *ppVertexRemap,  
                     LPD3DXMESH* ppOptMesh) PURE;
    STDMETHOD(OptimizeInplace)(THIS_ DWORD Flags, CONST DWORD* pAdjacencyIn, DWORD* pAdjacencyOut, 
                     DWORD* pFaceRemap, LPD3DXBUFFER *ppVertexRemap) PURE;
    STDMETHOD(SetAttributeTable)(THIS_ CONST D3DXATTRIBUTERANGE *pAttribTable, DWORD cAttribTableSize) PURE;
};


#undef INTERFACE
#define INTERFACE ID3DXPMesh

DECLARE_INTERFACE_(ID3DXPMesh, ID3DXBaseMesh)
{
    // IUnknown
    STDMETHOD(QueryInterface)(THIS_ REFIID iid, LPVOID *ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;

    // ID3DXBaseMesh
    STDMETHOD(DrawSubset)(THIS_ DWORD AttribId) PURE;
    STDMETHOD_(DWORD, GetNumFaces)(THIS) PURE;
    STDMETHOD_(DWORD, GetNumVertices)(THIS) PURE;
    STDMETHOD_(DWORD, GetFVF)(THIS) PURE;
    STDMETHOD(GetDeclaration)(THIS_ D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]) PURE;
    STDMETHOD_(DWORD, GetNumBytesPerVertex)(THIS) PURE;
    STDMETHOD_(DWORD, GetOptions)(THIS) PURE;
    STDMETHOD(GetDevice)(THIS_ LPDIRECT3DDEVICE9* ppDevice) PURE;
    STDMETHOD(CloneMeshFVF)(THIS_ DWORD Options, 
                DWORD FVF, LPDIRECT3DDEVICE9 pD3DDevice, LPD3DXMESH* ppCloneMesh) PURE;
    STDMETHOD(CloneMesh)(THIS_ DWORD Options, 
                CONST D3DVERTEXELEMENT9 *pDeclaration, LPDIRECT3DDEVICE9 pD3DDevice, LPD3DXMESH* ppCloneMesh) PURE;
    STDMETHOD(GetVertexBuffer)(THIS_ LPDIRECT3DVERTEXBUFFER9* ppVB) PURE;
    STDMETHOD(GetIndexBuffer)(THIS_ LPDIRECT3DINDEXBUFFER9* ppIB) PURE;
    STDMETHOD(LockVertexBuffer)(THIS_ DWORD Flags, LPVOID *ppData) PURE;
    STDMETHOD(UnlockVertexBuffer)(THIS) PURE;
    STDMETHOD(LockIndexBuffer)(THIS_ DWORD Flags, LPVOID *ppData) PURE;
    STDMETHOD(UnlockIndexBuffer)(THIS) PURE;
    STDMETHOD(GetAttributeTable)(
                THIS_ D3DXATTRIBUTERANGE *pAttribTable, DWORD* pAttribTableSize) PURE;

    STDMETHOD(ConvertPointRepsToAdjacency)(THIS_ CONST DWORD* pPRep, DWORD* pAdjacency) PURE;
    STDMETHOD(ConvertAdjacencyToPointReps)(THIS_ CONST DWORD* pAdjacency, DWORD* pPRep) PURE;
    STDMETHOD(GenerateAdjacency)(THIS_ FLOAT Epsilon, DWORD* pAdjacency) PURE;

    STDMETHOD(UpdateSemantics)(THIS_ D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]) PURE;

    // ID3DXPMesh
    STDMETHOD(ClonePMeshFVF)(THIS_ DWORD Options, 
                DWORD FVF, LPDIRECT3DDEVICE9 pD3D, LPD3DXPMESH* ppCloneMesh) PURE;
    STDMETHOD(ClonePMesh)(THIS_ DWORD Options, 
                CONST D3DVERTEXELEMENT9 *pDeclaration, LPDIRECT3DDEVICE9 pD3D, LPD3DXPMESH* ppCloneMesh) PURE;
    STDMETHOD(SetNumFaces)(THIS_ DWORD Faces) PURE;
    STDMETHOD(SetNumVertices)(THIS_ DWORD Vertices) PURE;
    STDMETHOD_(DWORD, GetMaxFaces)(THIS) PURE;
    STDMETHOD_(DWORD, GetMinFaces)(THIS) PURE;
    STDMETHOD_(DWORD, GetMaxVertices)(THIS) PURE;
    STDMETHOD_(DWORD, GetMinVertices)(THIS) PURE;
    STDMETHOD(Save)(THIS_ IStream *pStream, CONST D3DXMATERIAL* pMaterials, CONST D3DXEFFECTINSTANCE* pEffectInstances, DWORD NumMaterials) PURE;

    STDMETHOD(Optimize)(THIS_ DWORD Flags, DWORD* pAdjacencyOut, 
                     DWORD* pFaceRemap, LPD3DXBUFFER *ppVertexRemap,  
                     LPD3DXMESH* ppOptMesh) PURE;

    STDMETHOD(OptimizeBaseLOD)(THIS_ DWORD Flags, DWORD* pFaceRemap) PURE;
    STDMETHOD(TrimByFaces)(THIS_ DWORD NewFacesMin, DWORD NewFacesMax, DWORD *rgiFaceRemap, DWORD *rgiVertRemap) PURE;
    STDMETHOD(TrimByVertices)(THIS_ DWORD NewVerticesMin, DWORD NewVerticesMax, DWORD *rgiFaceRemap, DWORD *rgiVertRemap) PURE;

    STDMETHOD(GetAdjacency)(THIS_ DWORD* pAdjacency) PURE;

    //  Used to generate the immediate "ancestor" for each vertex when it is removed by a vsplit.  Allows generation of geomorphs
    //     Vertex buffer must be equal to or greater than the maximum number of vertices in the pmesh
    STDMETHOD(GenerateVertexHistory)(THIS_ DWORD* pVertexHistory) PURE;
};


#undef INTERFACE
#define INTERFACE ID3DXSPMesh

DECLARE_INTERFACE_(ID3DXSPMesh, IUnknown)
{
    // IUnknown
    STDMETHOD(QueryInterface)(THIS_ REFIID iid, LPVOID *ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;

    // ID3DXSPMesh
    STDMETHOD_(DWORD, GetNumFaces)(THIS) PURE;
    STDMETHOD_(DWORD, GetNumVertices)(THIS) PURE;
    STDMETHOD_(DWORD, GetFVF)(THIS) PURE;
    STDMETHOD(GetDeclaration)(THIS_ D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]) PURE;
    STDMETHOD_(DWORD, GetOptions)(THIS) PURE;
    STDMETHOD(GetDevice)(THIS_ LPDIRECT3DDEVICE9* ppDevice) PURE;
    STDMETHOD(CloneMeshFVF)(THIS_ DWORD Options, 
                DWORD FVF, LPDIRECT3DDEVICE9 pD3D, DWORD *pAdjacencyOut, DWORD *pVertexRemapOut, LPD3DXMESH* ppCloneMesh) PURE;
    STDMETHOD(CloneMesh)(THIS_ DWORD Options, 
                CONST D3DVERTEXELEMENT9 *pDeclaration, LPDIRECT3DDEVICE9 pD3DDevice, DWORD *pAdjacencyOut, DWORD *pVertexRemapOut, LPD3DXMESH* ppCloneMesh) PURE;
    STDMETHOD(ClonePMeshFVF)(THIS_ DWORD Options, 
                DWORD FVF, LPDIRECT3DDEVICE9 pD3D, DWORD *pVertexRemapOut, FLOAT *pErrorsByFace, LPD3DXPMESH* ppCloneMesh) PURE;
    STDMETHOD(ClonePMesh)(THIS_ DWORD Options, 
                CONST D3DVERTEXELEMENT9 *pDeclaration, LPDIRECT3DDEVICE9 pD3D, DWORD *pVertexRemapOut, FLOAT *pErrorsbyFace, LPD3DXPMESH* ppCloneMesh) PURE;
    STDMETHOD(ReduceFaces)(THIS_ DWORD Faces) PURE;
    STDMETHOD(ReduceVertices)(THIS_ DWORD Vertices) PURE;
    STDMETHOD_(DWORD, GetMaxFaces)(THIS) PURE;
    STDMETHOD_(DWORD, GetMaxVertices)(THIS) PURE;
    STDMETHOD(GetVertexAttributeWeights)(THIS_ LPD3DXATTRIBUTEWEIGHTS pVertexAttributeWeights) PURE;
    STDMETHOD(GetVertexWeights)(THIS_ FLOAT *pVertexWeights) PURE;
};

#define UNUSED16 (0xffff)
#define UNUSED32 (0xffffffff)

// ID3DXMesh::Optimize options - upper byte only, lower 3 bytes used from _D3DXMESH option flags
enum _D3DXMESHOPT {
    D3DXMESHOPT_COMPACT       = 0x01000000,
    D3DXMESHOPT_ATTRSORT      = 0x02000000,
    D3DXMESHOPT_VERTEXCACHE   = 0x04000000,
    D3DXMESHOPT_STRIPREORDER  = 0x08000000,
    D3DXMESHOPT_IGNOREVERTS   = 0x10000000,  // optimize faces only, don't touch vertices
    D3DXMESHOPT_DONOTSPLIT    = 0x20000000,  // do not split vertices shared between attribute groups when attribute sorting
    D3DXMESHOPT_DEVICEINDEPENDENT = 0x00400000,  // Only affects VCache.  uses a static known good cache size for all cards
                            
    // D3DXMESHOPT_SHAREVB has been removed, please use D3DXMESH_VB_SHARE instead

};

// Subset of the mesh that has the same attribute and bone combination.
// This subset can be rendered in a single draw call
typedef struct _D3DXBONECOMBINATION
{
    DWORD AttribId;
    DWORD FaceStart;
    DWORD FaceCount;
    DWORD VertexStart;
    DWORD VertexCount;
    DWORD* BoneId;
} D3DXBONECOMBINATION, *LPD3DXBONECOMBINATION;

// The following types of patch combinations are supported:
// Patch type   Basis       Degree
// Rect         Bezier      2,3,5
// Rect         B-Spline    2,3,5
// Rect         Catmull-Rom 3
// Tri          Bezier      2,3,5
// N-Patch      N/A         3

typedef struct _D3DXPATCHINFO
{
    D3DXPATCHMESHTYPE PatchType;
    D3DDEGREETYPE Degree;
    D3DBASISTYPE Basis;
} D3DXPATCHINFO, *LPD3DXPATCHINFO;

#undef INTERFACE
#define INTERFACE ID3DXPatchMesh

DECLARE_INTERFACE_(ID3DXPatchMesh, IUnknown)
{
    // IUnknown
    STDMETHOD(QueryInterface)(THIS_ REFIID iid, LPVOID *ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;

    // ID3DXPatchMesh

    // Return creation parameters
    STDMETHOD_(DWORD, GetNumPatches)(THIS) PURE;
    STDMETHOD_(DWORD, GetNumVertices)(THIS) PURE;
    STDMETHOD(GetDeclaration)(THIS_ LPD3DVERTEXELEMENT9) PURE;
    STDMETHOD_(DWORD, GetControlVerticesPerPatch)(THIS) PURE;
    STDMETHOD_(DWORD, GetOptions)(THIS) PURE;
    STDMETHOD(GetDevice)(THIS_ LPDIRECT3DDEVICE9 *ppDevice) PURE;
    STDMETHOD(GetPatchInfo)(THIS_ LPD3DXPATCHINFO PatchInfo) PURE;

    // Control mesh access    
    STDMETHOD(GetVertexBuffer)(THIS_ LPDIRECT3DVERTEXBUFFER9* ppVB) PURE;
    STDMETHOD(GetIndexBuffer)(THIS_ LPDIRECT3DINDEXBUFFER9* ppIB) PURE;
    STDMETHOD(LockVertexBuffer)(THIS_ DWORD flags, LPVOID *ppData) PURE;
    STDMETHOD(UnlockVertexBuffer)(THIS) PURE;
    STDMETHOD(LockIndexBuffer)(THIS_ DWORD flags, LPVOID *ppData) PURE;
    STDMETHOD(UnlockIndexBuffer)(THIS) PURE;
    STDMETHOD(LockAttributeBuffer)(THIS_ DWORD flags, DWORD** ppData) PURE;
    STDMETHOD(UnlockAttributeBuffer)(THIS) PURE;

    // This function returns the size of the tessellated mesh given a tessellation level.
    // This assumes uniform tessellation. For adaptive tessellation the Adaptive parameter must
    // be set to TRUE and TessellationLevel should be the max tessellation.
    // This will result in the max mesh size necessary for adaptive tessellation.    
    STDMETHOD(GetTessSize)(THIS_ FLOAT fTessLevel,DWORD Adapative, DWORD *NumTriangles,DWORD *NumVertices) PURE;
    
    //GenerateAdjacency determines which patches are adjacent with provided tolerance
    //this information is used internally to optimize tessellation
    STDMETHOD(GenerateAdjacency)(THIS_ FLOAT Tolerance) PURE;
    
    //CloneMesh Creates a new patchmesh with the specified decl, and converts the vertex buffer
    //to the new decl. Entries in the new decl which are new are set to 0. If the current mesh
    //has adjacency, the new mesh will also have adjacency
    STDMETHOD(CloneMesh)(THIS_ DWORD Options, CONST D3DVERTEXELEMENT9 *pDecl, LPD3DXPATCHMESH *pMesh) PURE;
    
    // Optimizes the patchmesh for efficient tessellation. This function is designed
    // to perform one time optimization for patch meshes that need to be tessellated
    // repeatedly by calling the Tessellate() method. The optimization performed is
    // independent of the actual tessellation level used.
    // Currently Flags is unused.
    // If vertices are changed, Optimize must be called again
    STDMETHOD(Optimize)(THIS_ DWORD flags) PURE;

    //gets and sets displacement parameters
    //displacement maps can only be 2D textures MIP-MAPPING is ignored for non adapative tessellation
    STDMETHOD(SetDisplaceParam)(THIS_ LPDIRECT3DBASETEXTURE9 Texture,
                              D3DTEXTUREFILTERTYPE MinFilter,
                              D3DTEXTUREFILTERTYPE MagFilter,
                              D3DTEXTUREFILTERTYPE MipFilter,
                              D3DTEXTUREADDRESS Wrap,
                              DWORD dwLODBias) PURE;

    STDMETHOD(GetDisplaceParam)(THIS_ LPDIRECT3DBASETEXTURE9 *Texture,
                                D3DTEXTUREFILTERTYPE *MinFilter,
                                D3DTEXTUREFILTERTYPE *MagFilter,
                                D3DTEXTUREFILTERTYPE *MipFilter,
                                D3DTEXTUREADDRESS *Wrap,
                                DWORD *dwLODBias) PURE;
        
    // Performs the uniform tessellation based on the tessellation level. 
    // This function will perform more efficiently if the patch mesh has been optimized using the Optimize() call.
    STDMETHOD(Tessellate)(THIS_ FLOAT fTessLevel,LPD3DXMESH pMesh) PURE;

    // Performs adaptive tessellation based on the Z based adaptive tessellation criterion.
    // pTrans specifies a 4D vector that is dotted with the vertices to get the per vertex
    // adaptive tessellation amount. Each edge is tessellated to the average of the criterion
    // at the 2 vertices it connects.
    // MaxTessLevel specifies the upper limit for adaptive tesselation.
    // This function will perform more efficiently if the patch mesh has been optimized using the Optimize() call.
    STDMETHOD(TessellateAdaptive)(THIS_ 
        CONST D3DXVECTOR4 *pTrans,
        DWORD dwMaxTessLevel, 
        DWORD dwMinTessLevel,
        LPD3DXMESH pMesh) PURE;

};

#undef INTERFACE
#define INTERFACE ID3DXSkinInfo

DECLARE_INTERFACE_(ID3DXSkinInfo, IUnknown)
{
    // IUnknown
    STDMETHOD(QueryInterface)(THIS_ REFIID iid, LPVOID *ppv) PURE;
    STDMETHOD_(ULONG, AddRef)(THIS) PURE;
    STDMETHOD_(ULONG, Release)(THIS) PURE;

    // Specify the which vertices do each bones influence and by how much
    STDMETHOD(SetBoneInfluence)(THIS_ DWORD bone, DWORD numInfluences, CONST DWORD* vertices, CONST FLOAT* weights) PURE;
    STDMETHOD_(DWORD, GetNumBoneInfluences)(THIS_ DWORD bone) PURE;
    STDMETHOD(GetBoneInfluence)(THIS_ DWORD bone, DWORD* vertices, FLOAT* weights) PURE;
    STDMETHOD(GetMaxVertexInfluences)(THIS_ DWORD* maxVertexInfluences) PURE;
    STDMETHOD_(DWORD, GetNumBones)(THIS) PURE;

    // This gets the max face influences based on a triangle mesh with the specified index buffer
    STDMETHOD(GetMaxFaceInfluences)(THIS_ LPDIRECT3DINDEXBUFFER9 pIB, DWORD NumFaces, DWORD* maxFaceInfluences) PURE;
    
    // Set min bone influence. Bone influences that are smaller than this are ignored
    STDMETHOD(SetMinBoneInfluence)(THIS_ FLOAT MinInfl) PURE;
    // Get min bone influence. 
    STDMETHOD_(FLOAT, GetMinBoneInfluence)(THIS) PURE;
    
    // Bone names are returned by D3DXLoadSkinMeshFromXof. They are not used by any other method of this object
    STDMETHOD(SetBoneName)(THIS_ DWORD Bone, LPCSTR pName) PURE; // pName is copied to an internal string buffer
    STDMETHOD_(LPCSTR, GetBoneName)(THIS_ DWORD Bone) PURE; // A pointer to an internal string buffer is returned. Do not free this.
    
    // Bone offset matrices are returned by D3DXLoadSkinMeshFromXof. They are not used by any other method of this object
    STDMETHOD(SetBoneOffsetMatrix)(THIS_ DWORD Bone, CONST D3DXMATRIX *pBoneTransform) PURE; // pBoneTransform is copied to an internal buffer
    STDMETHOD_(LPD3DXMATRIX, GetBoneOffsetMatrix)(THIS_ DWORD Bone) PURE; // A pointer to an internal matrix is returned. Do not free this.
    
    // Clone a skin info object
    STDMETHOD(Clone)(THIS_ LPD3DXSKININFO* ppSkinInfo) PURE;
    
    // Update bone influence information to match vertices after they are reordered. This should be called 
    // if the target vertex buffer has been reordered externally.
    STDMETHOD(Remap)(THIS_ DWORD NumVertices, DWORD* pVertexRemap) PURE;

    // These methods enable the modification of the vertex layout of the vertices that will be skinned
    STDMETHOD(SetFVF)(THIS_ DWORD FVF) PURE;
    STDMETHOD(SetDeclaration)(THIS_ CONST D3DVERTEXELEMENT9 *pDeclaration) PURE;
    STDMETHOD_(DWORD, GetFVF)(THIS) PURE;
    STDMETHOD(GetDeclaration)(THIS_ D3DVERTEXELEMENT9 Declaration[MAX_FVF_DECL_SIZE]) PURE;

    // Apply SW skinning based on current pose matrices to the target vertices.
    STDMETHOD(UpdateSkinnedMesh)(THIS_ 
        CONST D3DXMATRIX* pBoneTransforms, 
        CONST D3DXMATRIX* pBoneInvTransposeTransforms, 
        LPCVOID pVerticesSrc, 
        PVOID pVerticesDst) PURE;

    // Takes a mesh and returns a new mesh with per vertex blend weights and a bone combination
    // table that describes which bones affect which subsets of the mesh
    STDMETHOD(ConvertToBlendedMesh)(THIS_ 
        LPD3DXMESH pMesh,
        DWORD Options, 
        CONST DWORD *pAdjacencyIn, 
        LPDWORD pAdjacencyOut,
        DWORD* pFaceRemap, 
        LPD3DXBUFFER *ppVertexRemap, 
        DWORD* pMaxFaceInfl,
        DWORD* pNumBoneCombinations, 
        LPD3DXBUFFER* ppBoneCombinationTable, 
        LPD3DXMESH* ppMesh) PURE;

    // Takes a mesh and returns a new mesh with per vertex blend weights and indices 
    // and a bone combination table that describes which bones palettes affect which subsets of the mesh
    STDMETHOD(ConvertToIndexedBlendedMesh)(THIS_ 
        LPD3DXMESH pMesh,
        DWORD Options, 
        DWORD paletteSize, 
        CONST DWORD *pAdjacencyIn, 
        LPDWORD pAdjacencyOut, 
        DWORD* pFaceRemap, 
        LPD3DXBUFFER *ppVertexRemap, 
        DWORD* pMaxVertexInfl,
        DWORD* pNumBoneCombinations, 
        LPD3DXBUFFER* ppBoneCombinationTable, 
        LPD3DXMESH* ppMesh) PURE;
};

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus


HRESULT WINAPI 
    D3DXCreateMesh(
        DWORD NumFaces, 
        DWORD NumVertices, 
        DWORD Options, 
        CONST D3DVERTEXELEMENT9 *pDeclaration, 
        LPDIRECT3DDEVICE9 pD3D, 
        LPD3DXMESH* ppMesh);

HRESULT WINAPI 
    D3DXCreateMeshFVF(
        DWORD NumFaces, 
        DWORD NumVertices, 
        DWORD Options, 
        DWORD FVF, 
        LPDIRECT3DDEVICE9 pD3D, 
        LPD3DXMESH* ppMesh);

HRESULT WINAPI 
    D3DXCreateSPMesh(
        LPD3DXMESH pMesh, 
        CONST DWORD* pAdjacency, 
        CONST D3DXATTRIBUTEWEIGHTS *pVertexAttributeWeights,
        CONST FLOAT *pVertexWeights,
        LPD3DXSPMESH* ppSMesh);

// clean a mesh up for simplification, try to make manifold
HRESULT WINAPI
    D3DXCleanMesh(
    LPD3DXMESH pMeshIn,
    CONST DWORD* pAdjacencyIn,
    LPD3DXMESH* ppMeshOut,
    DWORD* pAdjacencyOut,
    LPD3DXBUFFER* ppErrorsAndWarnings);

HRESULT WINAPI
    D3DXValidMesh(
    LPD3DXMESH pMeshIn,
    CONST DWORD* pAdjacency,
    LPD3DXBUFFER* ppErrorsAndWarnings);

HRESULT WINAPI 
    D3DXGeneratePMesh(
        LPD3DXMESH pMesh, 
        CONST DWORD* pAdjacency, 
        CONST D3DXATTRIBUTEWEIGHTS *pVertexAttributeWeights,
        CONST FLOAT *pVertexWeights,
        DWORD MinValue, 
        DWORD Options, 
        LPD3DXPMESH* ppPMesh);

HRESULT WINAPI 
    D3DXSimplifyMesh(
        LPD3DXMESH pMesh, 
        CONST DWORD* pAdjacency, 
        CONST D3DXATTRIBUTEWEIGHTS *pVertexAttributeWeights,
        CONST FLOAT *pVertexWeights,
        DWORD MinValue, 
        DWORD Options, 
        LPD3DXMESH* ppMesh);

HRESULT WINAPI 
    D3DXComputeBoundingSphere(
        CONST D3DXVECTOR3 *pFirstPosition,  // pointer to first position
        DWORD NumVertices, 
        DWORD dwStride,                     // count in bytes to subsequent position vectors
        D3DXVECTOR3 *pCenter, 
        FLOAT *pRadius);

HRESULT WINAPI 
    D3DXComputeBoundingBox(
        CONST D3DXVECTOR3 *pFirstPosition,  // pointer to first position
        DWORD NumVertices, 
        DWORD dwStride,                     // count in bytes to subsequent position vectors
        D3DXVECTOR3 *pMin, 
        D3DXVECTOR3 *pMax);

HRESULT WINAPI 
    D3DXComputeNormals(
        LPD3DXBASEMESH pMesh,
        CONST DWORD *pAdjacency);

HRESULT WINAPI 
    D3DXCreateBuffer(
        DWORD NumBytes, 
        LPD3DXBUFFER *ppBuffer);


HRESULT WINAPI
    D3DXLoadMeshFromXA(
        LPCSTR pFilename, 
        DWORD Options, 
        LPDIRECT3DDEVICE9 pD3D, 
        LPD3DXBUFFER *ppAdjacency,
        LPD3DXBUFFER *ppMaterials, 
        LPD3DXBUFFER *ppEffectInstances, 
        DWORD *pNumMaterials,
        LPD3DXMESH *ppMesh);

HRESULT WINAPI
    D3DXLoadMeshFromXW(
        LPCWSTR pFilename, 
        DWORD Options, 
        LPDIRECT3DDEVICE9 pD3D, 
        LPD3DXBUFFER *ppAdjacency,
        LPD3DXBUFFER *ppMaterials, 
        LPD3DXBUFFER *ppEffectInstances, 
        DWORD *pNumMaterials,
        LPD3DXMESH *ppMesh);

#ifdef UNICODE
#define D3DXLoadMeshFromX D3DXLoadMeshFromXW
#else
#define D3DXLoadMeshFromX D3DXLoadMeshFromXA
#endif

HRESULT WINAPI 
    D3DXLoadMeshFromXInMemory(
        LPCVOID Memory,
        DWORD SizeOfMemory,
        DWORD Options, 
        LPDIRECT3DDEVICE9 pD3D, 
        LPD3DXBUFFER *ppAdjacency,
        LPD3DXBUFFER *ppMaterials, 
        LPD3DXBUFFER *ppEffectInstances, 
        DWORD *pNumMaterials,
        LPD3DXMESH *ppMesh);

HRESULT WINAPI 
    D3DXLoadMeshFromXResource(
        HMODULE Module,
        LPCSTR Name,
        LPCSTR Type,
        DWORD Options, 
        LPDIRECT3DDEVICE9 pD3D, 
        LPD3DXBUFFER *ppAdjacency,
        LPD3DXBUFFER *ppMaterials, 
        LPD3DXBUFFER *ppEffectInstances, 
        DWORD *pNumMaterials,
        LPD3DXMESH *ppMesh);

HRESULT WINAPI 
    D3DXSaveMeshToXA(
        LPCSTR pFilename,
        LPD3DXMESH pMesh,
        CONST DWORD* pAdjacency,
        CONST D3DXMATERIAL* pMaterials,
        CONST D3DXEFFECTINSTANCE* pEffectInstances, 
        DWORD NumMaterials,
        DWORD Format
        );

HRESULT WINAPI 
    D3DXSaveMeshToXW(
        LPCWSTR pFilename,
        LPD3DXMESH pMesh,
        CONST DWORD* pAdjacency,
        CONST D3DXMATERIAL* pMaterials,
        CONST D3DXEFFECTINSTANCE* pEffectInstances, 
        DWORD NumMaterials,
        DWORD Format
        );
        
#ifdef UNICODE
#define D3DXSaveMeshToX D3DXSaveMeshToXW
#else
#define D3DXSaveMeshToX D3DXSaveMeshToXA
#endif
        

HRESULT WINAPI 
    D3DXCreatePMeshFromStream(
        IStream *pStream, 
        DWORD Options,
        LPDIRECT3DDEVICE9 pD3DDevice, 
        LPD3DXBUFFER *ppMaterials,
        LPD3DXBUFFER *ppEffectInstances, 
        DWORD* pNumMaterials,
        LPD3DXPMESH *ppPMesh);

// Creates a skin info object based on the number of vertices, number of bones, and a declaration describing the vertex layout of the target vertices
// The bone names and initial bone transforms are not filled in the skin info object by this method.
HRESULT WINAPI
    D3DXCreateSkinInfo(
        DWORD NumVertices,
        CONST D3DVERTEXELEMENT9 *pDeclaration, 
        DWORD NumBones,
        LPD3DXSKININFO* ppSkinInfo);
        
// Creates a skin info object based on the number of vertices, number of bones, and a FVF describing the vertex layout of the target vertices
// The bone names and initial bone transforms are not filled in the skin info object by this method.
HRESULT WINAPI
    D3DXCreateSkinInfoFVF(
        DWORD NumVertices,
        DWORD FVF,
        DWORD NumBones,
        LPD3DXSKININFO* ppSkinInfo);
        
#ifdef __cplusplus
}

extern "C" {
#endif //__cplusplus

HRESULT WINAPI 
    D3DXLoadMeshFromXof(
        LPDIRECTXFILEDATA pXofObjMesh, 
        DWORD Options, 
        LPDIRECT3DDEVICE9 pD3DDevice, 
        LPD3DXBUFFER *ppAdjacency,
        LPD3DXBUFFER *ppMaterials, 
        LPD3DXBUFFER *ppEffectInstances, 
        DWORD *pNumMaterials,
        LPD3DXMESH *ppMesh);

// This similar to D3DXLoadMeshFromXof, except also returns skinning info if present in the file
// If skinning info is not present, ppSkinInfo will be NULL     
HRESULT WINAPI
    D3DXLoadSkinMeshFromXof(
        LPDIRECTXFILEDATA pxofobjMesh, 
        DWORD Options,
        LPDIRECT3DDEVICE9 pD3D,
        LPD3DXBUFFER* ppAdjacency,
        LPD3DXBUFFER* ppMaterials,
        LPD3DXBUFFER *ppEffectInstances, 
        DWORD *pMatOut,
        LPD3DXSKININFO* ppSkinInfo,
        LPD3DXMESH* ppMesh);

// The inverse of D3DXConvertTo{Indexed}BlendedMesh() functions. It figures out the skinning info from
// the mesh and the bone combination table and populates a skin info object with that data. The bone
// names and initial bone transforms are not filled in the skin info object by this method. This works
// with either a non-indexed or indexed blended mesh. It examines the FVF or declarator of the mesh to
// determine what type it is.
HRESULT WINAPI
    D3DXCreateSkinInfoFromBlendedMesh(
        LPD3DXBASEMESH pMesh,
        DWORD NumBoneCombinations,
        CONST D3DXBONECOMBINATION *pBoneCombinationTable,
        LPD3DXSKININFO* ppSkinInfo);
        
HRESULT WINAPI
    D3DXTessellateNPatches(
        LPD3DXMESH pMeshIn,             
        CONST DWORD* pAdjacencyIn,             
        FLOAT NumSegs,                    
        BOOL  QuadraticInterpNormals,     // if false use linear intrep for normals, if true use quadratic
        LPD3DXMESH *ppMeshOut,
        LPD3DXBUFFER *ppAdjacencyOut);


//generates implied outputdecl from input decl
//the decl generated from this should be used to generate the output decl for
//the tessellator subroutines. 

HRESULT WINAPI
    D3DXGenerateOutputDecl(
        D3DVERTEXELEMENT9 *pOutput,
        CONST D3DVERTEXELEMENT9 *pInput);

//loads patches from an XFileData
//since an X file can have up to 6 different patch meshes in it,
//returns them in an array - pNumPatches will contain the number of
//meshes in the actual file. 
HRESULT WINAPI
    D3DXLoadPatchMeshFromXof(
        LPDIRECTXFILEDATA pXofObjMesh,
        DWORD Options,
        LPDIRECT3DDEVICE9 pDevice,
        LPD3DXBUFFER *ppMaterials,
        LPD3DXBUFFER *ppEffectInstances, 
        PDWORD pNumMaterials,
        LPD3DXPATCHMESH *ppMesh);

//computes the size a single rect patch.
HRESULT WINAPI
    D3DXRectPatchSize(
        CONST FLOAT *pfNumSegs, //segments for each edge (4)
        DWORD *pdwTriangles,    //output number of triangles
        DWORD *pdwVertices);    //output number of vertices

//computes the size of a single triangle patch      
HRESULT WINAPI
    D3DXTriPatchSize(
        CONST FLOAT *pfNumSegs, //segments for each edge (3)    
        DWORD *pdwTriangles,    //output number of triangles
        DWORD *pdwVertices);    //output number of vertices


//tessellates a patch into a created mesh
//similar to D3D RT patch
HRESULT WINAPI
    D3DXTessellateRectPatch(
        LPDIRECT3DVERTEXBUFFER9 pVB,
        CONST FLOAT *pNumSegs,
        CONST D3DVERTEXELEMENT9 *pdwInDecl,
        CONST D3DRECTPATCH_INFO *pRectPatchInfo,
        LPD3DXMESH pMesh);


HRESULT WINAPI
    D3DXTessellateTriPatch(
      LPDIRECT3DVERTEXBUFFER9 pVB,
      CONST FLOAT *pNumSegs,
      CONST D3DVERTEXELEMENT9 *pInDecl,
      CONST D3DTRIPATCH_INFO *pTriPatchInfo,
      LPD3DXMESH pMesh);



//creates an NPatch PatchMesh from a D3DXMESH 
HRESULT WINAPI
    D3DXCreateNPatchMesh(
        LPD3DXMESH pMeshSysMem,
        LPD3DXPATCHMESH *pPatchMesh);

      
//creates a patch mesh
HRESULT WINAPI
    D3DXCreatePatchMesh(
        CONST D3DXPATCHINFO *pInfo,     //patch type
        DWORD dwNumPatches,             //number of patches
        DWORD dwNumVertices,            //number of control vertices
        DWORD dwOptions,                //options 
        CONST D3DVERTEXELEMENT9 *pDecl, //format of control vertices
        LPDIRECT3DDEVICE9 pDevice, 
        LPD3DXPATCHMESH *pPatchMesh);

        
//returns the number of degenerates in a patch mesh -
//text output put in string.
HRESULT WINAPI
    D3DXValidPatchMesh(LPD3DXPATCHMESH pMesh,
                        DWORD *dwcDegenerateVertices,
                        DWORD *dwcDegeneratePatches,
                        LPD3DXBUFFER *ppErrorsAndWarnings);

UINT WINAPI
    D3DXGetFVFVertexSize(DWORD FVF);

UINT WINAPI 
    D3DXGetDeclVertexSize(CONST D3DVERTEXELEMENT9 *pDecl,DWORD Stream);

UINT WINAPI 
    D3DXGetDeclLength(CONST D3DVERTEXELEMENT9 *pDecl);

HRESULT WINAPI
    D3DXDeclaratorFromFVF(
        DWORD FVF,
        D3DVERTEXELEMENT9 pDeclarator[MAX_FVF_DECL_SIZE]);

HRESULT WINAPI
    D3DXFVFFromDeclarator(
        CONST D3DVERTEXELEMENT9 *pDeclarator,
        DWORD *pFVF);

HRESULT WINAPI 
    D3DXWeldVertices(
        LPD3DXMESH pMesh,         
        DWORD Flags,
        CONST D3DXWELDEPSILONS *pEpsilons,                 
        CONST DWORD *pAdjacencyIn, 
        DWORD *pAdjacencyOut,
        DWORD *pFaceRemap, 
        LPD3DXBUFFER *ppVertexRemap);

typedef struct _D3DXINTERSECTINFO
{
    DWORD FaceIndex;                // index of face intersected
    FLOAT U;                        // Barycentric Hit Coordinates    
    FLOAT V;                        // Barycentric Hit Coordinates
    FLOAT Dist;                     // Ray-Intersection Parameter Distance
} D3DXINTERSECTINFO, *LPD3DXINTERSECTINFO;


HRESULT WINAPI
    D3DXIntersect(
        LPD3DXBASEMESH pMesh,
        CONST D3DXVECTOR3 *pRayPos,
        CONST D3DXVECTOR3 *pRayDir, 
        BOOL    *pHit,              // True if any faces were intersected
        DWORD   *pFaceIndex,        // index of closest face intersected
        FLOAT   *pU,                // Barycentric Hit Coordinates    
        FLOAT   *pV,                // Barycentric Hit Coordinates
        FLOAT   *pDist,             // Ray-Intersection Parameter Distance
        LPD3DXBUFFER *ppAllHits,    // Array of D3DXINTERSECTINFOs for all hits (not just closest) 
        DWORD   *pCountOfHits);     // Number of entries in AllHits array

HRESULT WINAPI
    D3DXIntersectSubset(
        LPD3DXBASEMESH pMesh,
        DWORD AttribId,
        CONST D3DXVECTOR3 *pRayPos,
        CONST D3DXVECTOR3 *pRayDir, 
        BOOL    *pHit,              // True if any faces were intersected
        DWORD   *pFaceIndex,        // index of closest face intersected
        FLOAT   *pU,                // Barycentric Hit Coordinates    
        FLOAT   *pV,                // Barycentric Hit Coordinates
        FLOAT   *pDist,             // Ray-Intersection Parameter Distance
        LPD3DXBUFFER *ppAllHits,    // Array of D3DXINTERSECTINFOs for all hits (not just closest) 
        DWORD   *pCountOfHits);     // Number of entries in AllHits array


HRESULT WINAPI D3DXSplitMesh
    (
    LPD3DXMESH pMeshIn,         
    CONST DWORD *pAdjacencyIn, 
    CONST DWORD MaxSize,
    CONST DWORD Options,
    DWORD *pMeshesOut,
    LPD3DXBUFFER *ppMeshArrayOut,
    LPD3DXBUFFER *ppAdjacencyArrayOut,
    LPD3DXBUFFER *ppFaceRemapArrayOut,
    LPD3DXBUFFER *ppVertRemapArrayOut
    );

BOOL WINAPI D3DXIntersectTri 
(
    CONST D3DXVECTOR3 *p0,           // Triangle vertex 0 position
    CONST D3DXVECTOR3 *p1,           // Triangle vertex 1 position
    CONST D3DXVECTOR3 *p2,           // Triangle vertex 2 position
    CONST D3DXVECTOR3 *pRayPos,      // Ray origin
    CONST D3DXVECTOR3 *pRayDir,      // Ray direction
    FLOAT *pU,                       // Barycentric Hit Coordinates
    FLOAT *pV,                       // Barycentric Hit Coordinates
    FLOAT *pDist);                   // Ray-Intersection Parameter Distance

BOOL WINAPI
    D3DXSphereBoundProbe(
        CONST D3DXVECTOR3 *pCenter,
        FLOAT Radius,
        CONST D3DXVECTOR3 *pRayPosition,
        CONST D3DXVECTOR3 *pRayDirection);

BOOL WINAPI 
    D3DXBoxBoundProbe(
        CONST D3DXVECTOR3 *pMin, 
        CONST D3DXVECTOR3 *pMax,
        CONST D3DXVECTOR3 *pRayPosition,
        CONST D3DXVECTOR3 *pRayDirection);



//D3DXComputeTangent
//
//Computes the Tangent vectors for the TexStage texture coordinates
//and places the results in the TANGENT[TangentIndex] specified in the meshes' DECL
//puts the binorm in BINORM[BinormIndex] also specified in the decl.
//
//If neither the binorm or the tangnet are in the meshes declaration,
//the function will fail. 
//
//If a tangent or Binorm field is in the Decl, but the user does not
//wish D3DXComputeTangent to replace them, then D3DX_DEFAULT specified
//in the TangentIndex or BinormIndex will cause it to ignore the specified 
//semantic.
//
//Wrap should be specified if the texture coordinates wrap.

HRESULT WINAPI D3DXComputeTangent(LPD3DXMESH Mesh,
                                 DWORD TexStage,
                                 DWORD TangentIndex,
                                 DWORD BinormIndex,
                                 DWORD Wrap,
                                 CONST DWORD *pAdjacency);

HRESULT WINAPI
    D3DXConvertMeshSubsetToSingleStrip(
        LPD3DXBASEMESH MeshIn,
        DWORD AttribId,
        DWORD IBOptions,
        LPDIRECT3DINDEXBUFFER9 *ppIndexBuffer,
        DWORD *pNumIndices);

HRESULT WINAPI
    D3DXConvertMeshSubsetToStrips(
        LPD3DXBASEMESH MeshIn,
        DWORD AttribId,
        DWORD IBOptions,
        LPDIRECT3DINDEXBUFFER9 *ppIndexBuffer,
        DWORD *pNumIndices,
        LPD3DXBUFFER *ppStripLengths,
        DWORD *pNumStrips);

        
//============================================================================
//
//  D3DXOptimizeFaces:
//  --------------------
//  Generate a face remapping for a triangle list that more effectively utilizes
//    vertex caches.  This optimization is identical to the one provided
//    by ID3DXMesh::Optimize with the hardware independent option enabled.
//
//  Parameters:
//   pbIndices
//      Triangle list indices to use for generating a vertex ordering
//   NumFaces
//      Number of faces in the triangle list
//   NumVertices
//      Number of vertices referenced by the triangle list
//   b32BitIndices
//      TRUE if indices are 32 bit, FALSE if indices are 16 bit
//   pFaceRemap
//      Destination buffer to store face ordering
//      The number stored for a given element is where in the new ordering
//        the face will have come from.  See ID3DXMesh::Optimize for more info.
//
//============================================================================
HRESULT WINAPI
    D3DXOptimizeFaces(
        LPCVOID pbIndices, 
        UINT cFaces, 
        UINT cVertices, 
        BOOL b32BitIndices, 
        DWORD* pFaceRemap);
        
//============================================================================
//
//  D3DXOptimizeVertices:
//  --------------------
//  Generate a vertex remapping to optimize for in order use of vertices for 
//    a given set of indices.  This is commonly used after applying the face
//    remap generated by D3DXOptimizeFaces
//
//  Parameters:
//   pbIndices
//      Triangle list indices to use for generating a vertex ordering
//   NumFaces
//      Number of faces in the triangle list
//   NumVertices
//      Number of vertices referenced by the triangle list
//   b32BitIndices
//      TRUE if indices are 32 bit, FALSE if indices are 16 bit
//   pVertexRemap
//      Destination buffer to store vertex ordering
//      The number stored for a given element is where in the new ordering
//        the vertex will have come from.  See ID3DXMesh::Optimize for more info.
//
//============================================================================
HRESULT WINAPI
    D3DXOptimizeVertices(
        LPCVOID pbIndices, 
        UINT cFaces, 
        UINT cVertices, 
        BOOL b32BitIndices, 
        DWORD* pVertexRemap);

#ifdef __cplusplus
}
#endif //__cplusplus

//===========================================================================
//
//  Data structures for Spherical Harmonic Precomputation
//
//
//============================================================================


typedef enum _D3DXSHCOMPRESSQUALITYTYPE {
    D3DXSHCQUAL_FASTLOWQUALITY  = 1,
    D3DXSHCQUAL_SLOWHIGHQUALITY = 2,
    D3DXSHCQUAL_FORCE_DWORD     = 0x7fffffff
} D3DXSHCOMPRESSQUALITYTYPE;

// for all properties that are colors the red channel is used
// if the simulator is run with bSpectral FALSE

typedef struct _D3DXSHMATERIAL {
    D3DCOLORVALUE Diffuse;  // Diffuse albedo of the surface.  (Ignored if object is a Mirror)
    BOOL          bMirror;  // Must be set to FALSE.  bMirror == TRUE not currently supported
    BOOL          bSubSurf; // true if the object does subsurface scattering - can't do this and be a mirror

    // subsurface scattering parameters 
    FLOAT         RelativeIndexOfRefraction;
    D3DCOLORVALUE Absorption;
    D3DCOLORVALUE ReducedScattering;

} D3DXSHMATERIAL;

typedef struct _D3DXSHPRTBUFFER_DESC {
    UINT NumSamples;    // number of texels or vertices sampled
    UINT Order;         // order of spherical harmonics used 
    UINT NumChannels;
    UINT Width;
    UINT Height;
} D3DXSHPRTBUFFER_DESC;

typedef struct _D3DXSHPRTCOMPBUFFER_DESC {
    UINT SampleSize;
    UINT NumSamples;    // number of texels or vertices sampled
    UINT NumClusters;
    UINT NumPCA;                    
    UINT Order;         // order of spherical harmonics used 
    UINT NumChannels;
} D3DXSHPRTCOMPBUFFER_DESC;

// allocated in D3DXSHPRTCompSplitMeshSC
// vertices are duplicated into multiple super clusters but
// only have a valid status in one super cluster (fill in the rest)

typedef struct _D3DXSHPRTSPLITMESHVERTDATA {
    UINT  uVertRemap;   // vertex in original mesh this corresponds to
    UINT  uSubCluster;  // cluster index relative to super cluster
    UCHAR ucVertStatus; // 1 if vertex has valid data, 0 if it is "fill"
} D3DXSHPRTSPLITMESHVERTDATA;

// used in D3DXSHPRTCompSplitMeshSC
// information for each super cluster that maps into face/vert arrays

typedef struct _D3DXSHPRTSPLITMESHCLUSTERDATA {
    UINT uVertStart;     // initial index into remapped vertex array
    UINT uVertLength;    // number of vertices in this super cluster
    
    UINT uFaceStart;     // initial index into face array
    UINT uFaceLength;    // number of faces in this super cluster
    
    UINT uClusterStart;  // initial index into cluster array
    UINT uClusterLength; // number of clusters in this super cluster
} D3DXSHPRTSPLITMESHCLUSTERDATA;

// call back function for simulator
// return S_OK to keep running the simulator - anything else represents
// failure and the simulator will abort.

typedef HRESULT (WINAPI *LPD3DXSHPRTSIMCB)(float fPercentDone);

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus

//===========================================================================
//
//  Spherical Harmonic Precomputation Routines
//
// NOTE:
//  * These functions are intended for offline use, extraction routines can
//    be used at load time, but the simulators and compressor should only be
//    used when authoring content. 
//
//============================================================================

//============================================================================
//
//  D3DXSHPRTSimulation:
//  --------------------
//  Runs the PRT simulation on a set of input meshes using a corresponding 
//  set of materials.  This function can take a long time to run and should 
//  only done offline.
//
//  Parameters:
//   Order
//      Order of SH to use, generates Order^2 coeffs (Degree is Order - 1)
//   NumMeshes
//      Number of meshes in the scene, where each mesh has a unique material
//   ppScene
//      Meshes that represent the scene
//   ppMaterials
//      Materials for each corresponding mesh
//   NumRays
//      Number of rays to shoot at each vertex
//   NumBounces
//      Number of bounces simulated - if this is not zero inter-reflections 
//      are computed
//   EnableSubSurf
//      Indicates whether or not Subsurface Scattering is to be used
//   LengthScale
//      Scale used for subsurface scattering (1 would be a 1mm cube)
//   EnableSpectral
//      TRUE enables color bleeding by computing RGB transfer vectors
//      FALSE just uses the red channel for material properties
//   ppSimulationResults
//      Buffer that is allocated and filled in by the simulator
//   pProgressCallback
//      Optional function pointer that is called periodically
//      Must return S_OK or simulator exits
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTSimulation
        (
        UINT Order, 
        UINT NumMeshes, 
        LPD3DXMESH *ppScene,
        D3DXSHMATERIAL **ppMaterials,
        UINT NumRays, 
        UINT NumBounces,
        BOOL EnableSubSurf, 
        FLOAT LengthScale,
        BOOL EnableSpectral,
        LPD3DXBUFFER *ppSimulationResults,
        LPD3DXSHPRTSIMCB pProgressCallback
        );


//============================================================================
//
//  D3DXSHPRTExtractChannel:
//  ------------------------
//  Pulls the data for a given channel out of pSimulationResults
//
//  Parameters:
//   Order
//      Order of spherical harmonic coefficients to extract
//   pTransferCoefficients
//      Array of Order^2 floats into which transfer coefficients for the 
//      specified channel are written
//   Channel
//      Specifies the channel to extract (0/1/2 for R/G/B)
//   pSimulationResults
//      Buffer obtained from D3DXSHPRTSimulation
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTExtractChannel
        (
        UINT Order, 
        FLOAT *pTransferCoefficients, 
        UINT Channel, 
        LPD3DXBUFFER pSimulationResults
        );


//============================================================================
//
//  D3DXSHPRTGetRawDataPointer:
//  ---------------------------
//  Given a buffer that has been simulated, makes ppData reference the
//  raw data in the buffer.  This pointer is invalid after the buffer
//  has been released.  The data is formatted as follows:
//      FLOAT fRawData[NumSamples][NumChannels][Order*Order]
//  where NumSamples is the number of texels/vertices in the scene.
//
//  Parameters:
//   pSimulationResults
//      Buffer obtained from the simulator that contains transfer vectors
//   ppRawData
//      Returns a pointer to the raw data inside the buffer
//
//============================================================================
                        
HRESULT WINAPI
    D3DXSHPRTGetRawDataPointer
        (
        LPD3DXBUFFER pSimulationResults, 
        FLOAT **ppRawData
        );


//============================================================================
//
//  D3DXSHPRTExtractDesc:
//  ---------------------
//  Given the result of a PRT simulation, this function extracts its
//  description.
//
//  Parameters:
//   pSimulationResults
//      Buffer obtained from the simulator
//   pDesc
//      Structure to be filled in with information from the buffer
//      Width/Height non-zero only if the textured simulator was used
//
//============================================================================


HRESULT WINAPI
    D3DXSHPRTExtractDesc
        (
        LPD3DXBUFFER pSimulationResults, 
        D3DXSHPRTBUFFER_DESC *pDesc
        );

//============================================================================
//
//  D3DXSHPRTSimulationTex:
//  -----------------------
//  Runs the PRT simulation on an input mesh in texture space.  
//  Returns a buffer that contains PRT results for every texel.
//  This function can take a long time to run and should only done offline.
//
//  Parameters:
//   Order
//      Order of SH to use, generates Order^2 coeffs per channel per texel
//   pScene
//      Mesh that represents the scene
//   pMaterial
//      Material which specifies the albedo for the scene (if no albedo 
//      texture was specified), and the subsurface scattering properties
//   NumRays
//      Number of rays to shoot at each texel
//   NumBounces
//      Number of bounces simulated - if this is not zero inter-reflections 
//      are computed
//   EnableSubSurf
//      Indicates whether or not subsurface scattering is to be used
//   LengthScale
//      Scale used for subsurface scattering (1 would be a 1mm cube)
//   EnableSpectral
//      TRUE enables color bleeding by computing RGB transfer vectors
//      FALSE just uses the red channel for material properties
//   ppSimulationResults
//      Buffer that is allocated and filled in by the simulator
//   Width
//      Number of texels to sample across horizontally
//   Height
//      Number of texels to sample across vertically
//   pAlbedoTexture
//      Albedo (diffuse reflectance) of surface (can be NULL)
//   pProgressCallback
//      Optional function pointer that is called periodically  
//      (must return S_OK or simulator exits)
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTSimulationTex
        (
        UINT Order, 
        LPD3DXMESH pScene, 
        D3DXSHMATERIAL *pMaterial,
        UINT NumRays, 
        UINT NumBounces, 
        BOOL EnableSubSurf, 
        FLOAT LengthScale, 
        BOOL EnableSpectral,
        LPD3DXBUFFER *ppSimulationResults, 
        UINT Width, 
        UINT Height,
        LPDIRECT3DTEXTURE9 pAlbedoTexture,
        LPD3DXSHPRTSIMCB pProgressCallback
        );

//============================================================================
//
//  D3DXSHPRTExtractTexture:
//  ------------------------
//  Pulls the data for a given channel out of pSimulationResults.  
//  
//  Parameters:
//   Channel
//      Channel to be extracted.
//   StartCoefficient
//      Initial coefficient to extract 
//   NumCoefficients
//      Number of coefficients to extract
//   pSimulationResults
//      Buffer obtained from D3DXSHPRTSimulationTex
//   pTexture
//      Texture where data will be stored - must match dimensions specified
//      when simulator was run and be a signed or float format
//
//  Example:
//      For an order 4 simulation, there are 16 coefficients, which can be 
//      stored into four 4-channel textures by calling D3DXSPHRTExtractTexture 
//      4 times with NumCoefficients set to 4, and StartCoefficient set to 
//      0, 4, 8, and 12 in succession.
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTExtractTexture
        (
        UINT Channel, 
        UINT StartCoefficent, 
        UINT NumCoefficients,
        LPD3DXBUFFER pSimulationResults, 
        LPDIRECT3DTEXTURE9 pTexture
        );

//============================================================================
//
//  D3DXSHPRTExtractToMesh:
//  -----------------------
//  Pulls transfer coefficients from the buffer containing the simulation 
//  results and attaches them to the input mesh.
//  Can only be called on single channel buffers (use D3DXSHPRTExtractChannel 
//  otherwise).
//
//  Parameters:
//   Order
//      Order of SH to use, generates Order^2 coeffs, degree is Order-1
//   pScene
//      Single mesh that data is going to be packed into
//   pSimulationResults
//      Buffer obtained from D3DXSHPRTSimulation
//   Usage
//      D3DDECLUSAGE where coefficients are to be stored
//   UsageIndexStart
//      Starting index for coefficients to be stored
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTExtractToMesh
        (
        UINT Order, 
        LPD3DXMESH pScene, 
        LPD3DXBUFFER pSimulationResults,
        D3DDECLUSAGE Usage, 
        UINT UsageIndexStart
        );


//============================================================================
//
//  D3DXSHPRTCompress:
//  ------------------
//  This function compresses a PRT buffer, generating a new compressed
//  buffer.
//
//  Parameters:
//   Order
//      Order of SH to compress, generates Order^2 coeffs, degree is Order-1
//   pSimulationResults
//      Buffer obtained from the simulator that contains transfer vectors.
//   Quality
//      Type of compression to use 
//   NumClusters
//      Number of clusters to use for compression
//   NumPCA
//      Number of PCA vectors to use in each cluster
//   ppCompressedResults
//      Returns the compressed data
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTCompress
        (
        UINT Order, 
        LPD3DXBUFFER pSimulationResults,
        D3DXSHCOMPRESSQUALITYTYPE Quality,
        UINT NumClusters, 
        UINT NumPCA,
        LPD3DXBUFFER *ppCompressedResults
        );

//============================================================================
//
//  D3DXSHPRTCompExtractToMesh:
//  ---------------------------
//  Pulls PCA coefficients from compressed buffer and attaches them to the 
//  mesh.
//
//  Parameters:
//   NumPCA
//      Number of PCA coefficients to extract
//   pScene
//      Single mesh that data is going to be packed into
//   pCompressedResults
//      Buffer obtained from D3DXSHPRTCompress
//   Usage
//      D3DDECLUSAGE where coefficients are to be stored
//   UsageIndexStart
//      Starting index for coefficients to be stored
//
//============================================================================


HRESULT WINAPI 
    D3DXSHPRTCompExtractToMesh
        (
        UINT NumPCA, 
        LPD3DXMESH pScene, 
        LPD3DXBUFFER pCompressedResults,
        D3DDECLUSAGE Usage, 
        UINT UsageIndexStart
        );

//============================================================================
//
//  D3DXSHPRTCompExtractDesc:
//  -------------------------
//  Given a compressed buffer, extracts a description of the data.
//
//  Parameters:
//   pCompressedResults
//      Buffer obtained D3DXSHPRTCompress
//   pDesc
//      Structure to be filled in with information from the buffer
//
//============================================================================

HRESULT WINAPI
    D3DXSHPRTCompExtractDesc
        (
        LPD3DXBUFFER pCompressedResults, 
        D3DXSHPRTCOMPBUFFER_DESC *pDesc
        );

//============================================================================
//
//  D3DXSHPRTCompNormalizeData:
//  ---------------------------
//  Given a compressed buffer, rescales all of the PCA projection coefficients
//  so that they are within [-1, 1].  The PCA vectors are scaled so that 
//  reconstruction is still correct.  This maximizes precision when packing
//  into textures.
//
//  Parameters:
//   pCompressedResults
//      Buffer obtained from D3DXSHPRTCompress
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTCompNormalizeData
        (
        LPD3DXBUFFER pCompressedResults
        );

//============================================================================
//
//  D3DXSHPRTCompExtractBasis:
//  --------------------------
//  Extracts the mean + PCA basis vectors for a given cluster from a
//  compressed buffer.  The data is laid out in memory:
//      FLOAT fData[NumSamples][NumChannels][Order*Order]
//  Where NumSamples/NumChannels/Order are from the D3DXSHPRTCOMPBUFFER_DESC
//  that can be extracted from pBuffer.
//
//  Parameters:
//   Cluster
//      Cluster whose basis is going to be extracted
//   pCompressedResults
//      Buffer obtained from D3DXSHPRTCompress
//   pClusterBasis
//      Array of floats into which cluster basis is written
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTCompExtractBasis
        (
        UINT Cluster, 
        LPD3DXBUFFER pCompressedResults, 
        FLOAT *pClusterBasis
        );

//============================================================================
//
//  D3DXSHPRTCompExtractClusterIDs:
//  -------------------------------
//  Extracts the per sample cluster ID from a compressed data set.
//
//  Parameters:
//   pCompressedResults
//      Buffer obtained from D3DXSHPRTCompress
//   pClusterIDs
//      Pointer where D3DXSHPRTCOMPBUFFER_DESC::NumSamples IDs are written 
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTCompExtractClusterIDs
        (
        LPD3DXBUFFER pCompressedResults, 
        UINT *pClusterIDs
        );

//============================================================================
//
//  D3DXSHPRTCompExtractPCA:
//  ------------------------
//  Extracts the per-sample PCA coefficients from a compressed buffer.
//
//  Parameters:
//   StartPCA
//      Starting PCA projection coefficient to extract
//   NumExtract
//      Number of PCA projection coefficients to extract
//   pCompressedResults
//      Buffer obtained from D3DXSHPRTCompress
//   pPCACoefficients
//      Pointer where NumSamples * NumPCA PCA coefficients are written 
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTCompExtractPCA
        (
        UINT StartPCA, 
        UINT NumExtract, 
        LPD3DXBUFFER pCompressedResults, 
        FLOAT *pPCACoefficients
        );

//============================================================================
//
//  D3DXSHPRTCompExtractTexture:
//  ----------------------------
//  Extracts the per sample PCA coefficients from a compressed data set.  They
//  are extracted into a texture that has already been allocated.
//
//  Parameters:
//   StartPCA
//      Starting PCA projection coefficient to extract
//   NumExtract
//      Number of PCA projection coefficients to extract
//   pCompressedResults
//      Buffer obtained from D3DXSHPRTCompress
//   pTexture
//      Texture where data is stored - must match dimensions of simulator
//      and be a signed or floating point format
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTCompExtractTexture
        (
        UINT StartPCA, 
        UINT NumExtract, 
        LPD3DXBUFFER pCompressedResults, 
        LPDIRECT3DTEXTURE9 pTexture
        );

//============================================================================
//
//  D3DXSHPRTCompSuperCluster:
//  --------------------------
//  Used with compressed results of D3DXSHPRTSimulation.
//  Generates "super clusters" - groups of clusters that can be drawn in
//  the same draw call.  A greedy algorithm that minimizes overdraw is used
//  to group the clusters.
//
//  Parameters:
//   pClusterIDs
//      NumVerts cluster ID's (extracted from a compressed buffer)
//   pScene
//      Mesh that represents composite scene passed to the simulator
//   MaxNumClusters
//      Maximum number of clusters allocated per super cluster
//   NumClusters
//      Number of clusters computed in the simulator
//   pSuperClusterIDs
//      Array of length NumClusters, contains index of super cluster
//      that corresponding cluster was assigned to
//   pNumSuperClusters
//      Returns the number of super clusters allocated
//      
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTCompSuperCluster
        (
        UINT *pClusterIDs, 
        LPD3DXMESH pScene, 
        UINT MaxNumClusters, 
        UINT NumClusters,
        UINT *pSuperClusterIDs, 
        UINT *pNumSuperClusters
        );

//============================================================================
//
//  D3DXSHPRTCompSplitMeshSC:
//  -------------------------
//  Used with compressed results of the vertex version of the PRT simulator.
//  After D3DXSHRTCompSuperCluster has been called this function can be used
//  to split the mesh into a group of faces/vertices per super cluster.
//  Each super cluster contains all of the faces that contain any vertex
//  classified in one of its clusters.  All of the vertices connected to this
//  set of faces are also included with the returned array ppVertStatus 
//  indicating whether or not the vertex belongs to the supercluster.
//
//  Parameters:
//   pClusterIDs
//      NumVerts cluster ID's (extracted from a compressed buffer)
//   NumVertices
//      Number of vertices in original mesh
//   NumClusters
//      Number of clusters (input parameter to compression)
//   pSuperClusterIDs
//      Array of size NumClusters that will contain super cluster ID's (from
//      D3DXSHCompSuerCluster)
//   NumSuperClusters
//      Number of superclusters allocated in D3DXSHCompSuerCluster
//   pInputIB
//      Raw index buffer for mesh - format depends on bInputIBIs32Bit
//   InputIBIs32Bit
//      Indicates whether the input index buffer is 32-bit (otherwise 16-bit
//      is assumed)
//   NumFaces
//      Number of faces in the original mesh (pInputIB is 3 times this length)
//   ppIBData
//      Raw index buffer that will contain the resulting split faces.  Format
//      determined by bIBIs32Bit.  Allocated by function
//   pIBDataLength
//      Length of ppIBData, assigned in function
//   OutputIBIs32Bit
//      Indicates whether the output index buffer is to be 32-bit (otherwise 
//      16-bit is assumed)
//   ppFaceRemap
//      Mapping of each face in ppIBData to original faces.  Length is
//      *pIBDataLength/3.  Allocated in function
//   ppVertData
//      New vertex data structure.  Size of pVertDataLength
//   pVertDataLength
//      Number of new vertices in split mesh.  Assigned in function
//   pSCClusterList
//      Array of length NumClusters which pSCData indexes into (Cluster* fields)
//      for each SC, contains clusters sorted by super cluster
//   pSCData
//      Structure per super cluster - contains indices into ppIBData,
//      pSCClusterList and ppVertData
//
//============================================================================

HRESULT WINAPI 
    D3DXSHPRTCompSplitMeshSC
        (
        UINT *pClusterIDs, 
        UINT NumVertices, 
        UINT NumClusters, 
        UINT *pSuperClusterIDs, 
        UINT NumSuperClusters,
        LPVOID pInputIB, 
        BOOL InputIBIs32Bit, 
        UINT NumFaces,
        LPVOID *ppIBData, 
        UINT *pIBDataLength, 
        BOOL OutputIBIs32Bit, 
        UINT **ppFaceRemap, 
        D3DXSHPRTSPLITMESHVERTDATA **ppVertData, 
        UINT *pVertDataLength, 
        UINT *pSCClusterList,
        D3DXSHPRTSPLITMESHCLUSTERDATA *pSCData
        );

#ifdef __cplusplus
}
#endif //__cplusplus


//////////////////////////////////////////////////////////////////////////////
//
//  Definitions of .X file templates used by mesh load/save functions 
//    that are not RM standard
//
//////////////////////////////////////////////////////////////////////////////

// {3CF169CE-FF7C-44ab-93C0-F78F62D172E2}
DEFINE_GUID(DXFILEOBJ_XSkinMeshHeader,
0x3cf169ce, 0xff7c, 0x44ab, 0x93, 0xc0, 0xf7, 0x8f, 0x62, 0xd1, 0x72, 0xe2);

// {B8D65549-D7C9-4995-89CF-53A9A8B031E3}
DEFINE_GUID(DXFILEOBJ_VertexDuplicationIndices, 
0xb8d65549, 0xd7c9, 0x4995, 0x89, 0xcf, 0x53, 0xa9, 0xa8, 0xb0, 0x31, 0xe3);

// {A64C844A-E282-4756-8B80-250CDE04398C}
DEFINE_GUID(DXFILEOBJ_FaceAdjacency, 
0xa64c844a, 0xe282, 0x4756, 0x8b, 0x80, 0x25, 0xc, 0xde, 0x4, 0x39, 0x8c);

// {6F0D123B-BAD2-4167-A0D0-80224F25FABB}
DEFINE_GUID(DXFILEOBJ_SkinWeights, 
0x6f0d123b, 0xbad2, 0x4167, 0xa0, 0xd0, 0x80, 0x22, 0x4f, 0x25, 0xfa, 0xbb);

// {A3EB5D44-FC22-429d-9AFB-3221CB9719A6}
DEFINE_GUID(DXFILEOBJ_Patch, 
0xa3eb5d44, 0xfc22, 0x429d, 0x9a, 0xfb, 0x32, 0x21, 0xcb, 0x97, 0x19, 0xa6);

// {D02C95CC-EDBA-4305-9B5D-1820D7704BBF}
DEFINE_GUID(DXFILEOBJ_PatchMesh, 
0xd02c95cc, 0xedba, 0x4305, 0x9b, 0x5d, 0x18, 0x20, 0xd7, 0x70, 0x4b, 0xbf);

// {B9EC94E1-B9A6-4251-BA18-94893F02C0EA}
DEFINE_GUID(DXFILEOBJ_PatchMesh9, 
0xb9ec94e1, 0xb9a6, 0x4251, 0xba, 0x18, 0x94, 0x89, 0x3f, 0x2, 0xc0, 0xea);

// {B6C3E656-EC8B-4b92-9B62-681659522947}
DEFINE_GUID(DXFILEOBJ_PMInfo, 
0xb6c3e656, 0xec8b, 0x4b92, 0x9b, 0x62, 0x68, 0x16, 0x59, 0x52, 0x29, 0x47);

// {917E0427-C61E-4a14-9C64-AFE65F9E9844}
DEFINE_GUID(DXFILEOBJ_PMAttributeRange, 
0x917e0427, 0xc61e, 0x4a14, 0x9c, 0x64, 0xaf, 0xe6, 0x5f, 0x9e, 0x98, 0x44);

// {574CCC14-F0B3-4333-822D-93E8A8A08E4C}
DEFINE_GUID(DXFILEOBJ_PMVSplitRecord,
0x574ccc14, 0xf0b3, 0x4333, 0x82, 0x2d, 0x93, 0xe8, 0xa8, 0xa0, 0x8e, 0x4c);

// {B6E70A0E-8EF9-4e83-94AD-ECC8B0C04897}
DEFINE_GUID(DXFILEOBJ_FVFData, 
0xb6e70a0e, 0x8ef9, 0x4e83, 0x94, 0xad, 0xec, 0xc8, 0xb0, 0xc0, 0x48, 0x97);

// {F752461C-1E23-48f6-B9F8-8350850F336F}
DEFINE_GUID(DXFILEOBJ_VertexElement, 
0xf752461c, 0x1e23, 0x48f6, 0xb9, 0xf8, 0x83, 0x50, 0x85, 0xf, 0x33, 0x6f);

// {BF22E553-292C-4781-9FEA-62BD554BDD93}
DEFINE_GUID(DXFILEOBJ_DeclData, 
0xbf22e553, 0x292c, 0x4781, 0x9f, 0xea, 0x62, 0xbd, 0x55, 0x4b, 0xdd, 0x93);

// {F1CFE2B3-0DE3-4e28-AFA1-155A750A282D}
DEFINE_GUID(DXFILEOBJ_EffectFloats, 
0xf1cfe2b3, 0xde3, 0x4e28, 0xaf, 0xa1, 0x15, 0x5a, 0x75, 0xa, 0x28, 0x2d);

// {D55B097E-BDB6-4c52-B03D-6051C89D0E42}
DEFINE_GUID(DXFILEOBJ_EffectString, 
0xd55b097e, 0xbdb6, 0x4c52, 0xb0, 0x3d, 0x60, 0x51, 0xc8, 0x9d, 0xe, 0x42);

// {622C0ED0-956E-4da9-908A-2AF94F3CE716}
DEFINE_GUID(DXFILEOBJ_EffectDWord, 
0x622c0ed0, 0x956e, 0x4da9, 0x90, 0x8a, 0x2a, 0xf9, 0x4f, 0x3c, 0xe7, 0x16);

// {3014B9A0-62F5-478c-9B86-E4AC9F4E418B}
DEFINE_GUID(DXFILEOBJ_EffectParamFloats, 
0x3014b9a0, 0x62f5, 0x478c, 0x9b, 0x86, 0xe4, 0xac, 0x9f, 0x4e, 0x41, 0x8b);

// {1DBC4C88-94C1-46ee-9076-2C28818C9481}
DEFINE_GUID(DXFILEOBJ_EffectParamString, 
0x1dbc4c88, 0x94c1, 0x46ee, 0x90, 0x76, 0x2c, 0x28, 0x81, 0x8c, 0x94, 0x81);

// {E13963BC-AE51-4c5d-B00F-CFA3A9D97CE5}
DEFINE_GUID(DXFILEOBJ_EffectParamDWord,
0xe13963bc, 0xae51, 0x4c5d, 0xb0, 0xf, 0xcf, 0xa3, 0xa9, 0xd9, 0x7c, 0xe5);

// {E331F7E4-0559-4cc2-8E99-1CEC1657928F}
DEFINE_GUID(DXFILEOBJ_EffectInstance, 
0xe331f7e4, 0x559, 0x4cc2, 0x8e, 0x99, 0x1c, 0xec, 0x16, 0x57, 0x92, 0x8f);

// {9E415A43-7BA6-4a73-8743-B73D47E88476}
DEFINE_GUID(DXFILEOBJ_AnimTicksPerSecond, 
0x9e415a43, 0x7ba6, 0x4a73, 0x87, 0x43, 0xb7, 0x3d, 0x47, 0xe8, 0x84, 0x76);

#define XSKINEXP_TEMPLATES \
        "xof 0303txt 0032\
        template XSkinMeshHeader \
        { \
            <3CF169CE-FF7C-44ab-93C0-F78F62D172E2> \
            WORD nMaxSkinWeightsPerVertex; \
            WORD nMaxSkinWeightsPerFace; \
            WORD nBones; \
        } \
        template VertexDuplicationIndices \
        { \
            <B8D65549-D7C9-4995-89CF-53A9A8B031E3> \
            DWORD nIndices; \
            DWORD nOriginalVertices; \
            array DWORD indices[nIndices]; \
        } \
        template FaceAdjacency \
        { \
            <A64C844A-E282-4756-8B80-250CDE04398C> \
            DWORD nIndices; \
            array DWORD indices[nIndices]; \
        } \
        template SkinWeights \
        { \
            <6F0D123B-BAD2-4167-A0D0-80224F25FABB> \
            STRING transformNodeName; \
            DWORD nWeights; \
            array DWORD vertexIndices[nWeights]; \
            array float weights[nWeights]; \
            Matrix4x4 matrixOffset; \
        } \
        template Patch \
        { \
            <A3EB5D44-FC22-429D-9AFB-3221CB9719A6> \
            DWORD nControlIndices; \
            array DWORD controlIndices[nControlIndices]; \
        } \
        template PatchMesh \
        { \
            <D02C95CC-EDBA-4305-9B5D-1820D7704BBF> \
            DWORD nVertices; \
            array Vector vertices[nVertices]; \
            DWORD nPatches; \
            array Patch patches[nPatches]; \
            [ ... ] \
        } \
        template PatchMesh9 \
        { \
            <B9EC94E1-B9A6-4251-BA18-94893F02C0EA> \
            DWORD Type; \
            DWORD Degree; \
            DWORD Basis; \
            DWORD nVertices; \
            array Vector vertices[nVertices]; \
            DWORD nPatches; \
            array Patch patches[nPatches]; \
            [ ... ] \
        } " \
        "template EffectFloats \
        { \
            <F1CFE2B3-0DE3-4e28-AFA1-155A750A282D> \
            DWORD nFloats; \
            array float Floats[nFloats]; \
        } \
        template EffectString \
        { \
            <D55B097E-BDB6-4c52-B03D-6051C89D0E42> \
            STRING Value; \
        } \
        template EffectDWord \
        { \
            <622C0ED0-956E-4da9-908A-2AF94F3CE716> \
            DWORD Value; \
        } " \
        "template EffectParamFloats \
        { \
            <3014B9A0-62F5-478c-9B86-E4AC9F4E418B> \
            STRING ParamName; \
            DWORD nFloats; \
            array float Floats[nFloats]; \
        } " \
        "template EffectParamString \
        { \
            <1DBC4C88-94C1-46ee-9076-2C28818C9481> \
            STRING ParamName; \
            STRING Value; \
        } \
        template EffectParamDWord \
        { \
            <E13963BC-AE51-4c5d-B00F-CFA3A9D97CE5> \
            STRING ParamName; \
            DWORD Value; \
        } \
        template EffectInstance \
        { \
            <E331F7E4-0559-4cc2-8E99-1CEC1657928F> \
            STRING EffectFilename; \
            [ ... ] \
        } " \
        "template AnimTicksPerSecond \
        { \
            <9E415A43-7BA6-4a73-8743-B73D47E88476> \
            DWORD AnimTicksPerSecond; \
        } "

#define XEXTENSIONS_TEMPLATES \
        "xof 0303txt 0032\
        template FVFData \
        { \
            <B6E70A0E-8EF9-4e83-94AD-ECC8B0C04897> \
            DWORD dwFVF; \
            DWORD nDWords; \
            array DWORD data[nDWords]; \
        } \
        template VertexElement \
        { \
            <F752461C-1E23-48f6-B9F8-8350850F336F> \
            DWORD Type; \
            DWORD Method; \
            DWORD Usage; \
            DWORD UsageIndex; \
        } \
        template DeclData \
        { \
            <BF22E553-292C-4781-9FEA-62BD554BDD93> \
            DWORD nElements; \
            array VertexElement Elements[nElements]; \
            DWORD nDWords; \
            array DWORD data[nDWords]; \
        } \
        template PMAttributeRange \
        { \
            <917E0427-C61E-4a14-9C64-AFE65F9E9844> \
            DWORD iFaceOffset; \
            DWORD nFacesMin; \
            DWORD nFacesMax; \
            DWORD iVertexOffset; \
            DWORD nVerticesMin; \
            DWORD nVerticesMax; \
        } \
        template PMVSplitRecord \
        { \
            <574CCC14-F0B3-4333-822D-93E8A8A08E4C> \
            DWORD iFaceCLW; \
            DWORD iVlrOffset; \
            DWORD iCode; \
        } \
        template PMInfo \
        { \
            <B6C3E656-EC8B-4b92-9B62-681659522947> \
            DWORD nAttributes; \
            array PMAttributeRange attributeRanges[nAttributes]; \
            DWORD nMaxValence; \
            DWORD nMinLogicalVertices; \
            DWORD nMaxLogicalVertices; \
            DWORD nVSplits; \
            array PMVSplitRecord splitRecords[nVSplits]; \
            DWORD nAttributeMispredicts; \
            array DWORD attributeMispredicts[nAttributeMispredicts]; \
        } "
        
#endif //__D3DX9MESH_H__


