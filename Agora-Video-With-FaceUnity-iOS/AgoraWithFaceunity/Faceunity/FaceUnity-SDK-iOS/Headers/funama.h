#ifndef __FUNAMA_H
#define __FUNAMA_H
#ifdef _WIN32
#define FUNAMA_API __declspec(dllexport)
#else
#define FUNAMA_API
#endif

typedef enum FUAITYPE{
	FUAITYPE_BACKGROUNDSEGMENTATION=1<<1,
	FUAITYPE_HAIRSEGMENTATION=1<<2,
	FUAITYPE_HANDGESTURE=1<<3,
	FUAITYPE_TONGUETRACKING=1<<4,
	FUAITYPE_FACELANDMARKS75=1<<5,
	FUAITYPE_FACELANDMARKS209=1<<6,
	FUAITYPE_FACELANDMARKS239=1<<7,
	FUAITYPE_HUMANPOSE2D=1<<8,
	FUAITYPE_BACKGROUNDSEGMENTATION_GREEN=1<<9,
	FUAITYPE_FACEPROCESSOR=1<<10
}FUAITYPE;

/*\brief An I/O format where `ptr` points to a BGRA buffer. It matches the camera format on iOS. */
#define FU_FORMAT_BGRA_BUFFER 0
/*\brief An I/O format where `ptr` points to a single GLuint that is a RGBA texture. It matches the hardware encoding format on Android. */
#define FU_FORMAT_RGBA_TEXTURE 1
/*\brief An I/O format where `ptr` points to an NV21 buffer. It matches the camera preview format on Android. */
#define FU_FORMAT_NV21_BUFFER 2
#define FU_FORMAT_I420_BUFFER 13

/*\brief An output-only format where `out_ptr` is NULL or points to a TGLRenderingDesc structure. 
	The result is rendered onto the current GL framebuffer no matter what `out_ptr` is.
	If a TGLRenderingDesc is specified, we can optionally return an image to the caller in the specified format.
*/
#define FU_FORMAT_GL_CURRENT_FRAMEBUFFER 3
/*\brief An I/O format where `ptr` points to a RGBA buffer. */
#define FU_FORMAT_RGBA_BUFFER 4
/*\brief An input-only format where `ptr` points to a TCameraDesc struct. The input is directly taken from the specified camera. w and h are taken as the preferred image size*/
#define FU_FORMAT_CAMERA 5
/*\brief An input-only format where `in_ptr` points to a single GLuint that is an EXTERNAL_OES texture. It matches the hardware encoding format on Android. */
#define FU_FORMAT_RGBA_TEXTURE_EXTERNAL_OES 6
/*\brief An I/O format where `in_ptr` points to a TAndroidDualMode struct, which provides both a texture and an NV21 buffer as input. 
As the name suggests, this is the most efficient interface  on Android. */
#define FU_FORMAT_ANDROID_DUAL_MODE 7
typedef struct{
	int camera_id;//<which camera should we use, 0 for front, 1 for back
}TCameraDesc;
/*\brief Indicate that the `tex` member is an EXTERNAL_OES texture */
#define FU_ADM_FLAG_EXTERNAL_OES_TEXTURE 1
/*\brief Indicate that the result should also be read back to p_NV21 */
#define FU_ADM_FLAG_ENABLE_READBACK 2
/*\brief Indicate that the input texture is a packed NV21 texture */
#define FU_ADM_FLAG_NV21_TEXTURE 4
/*\brief Indicate that the input texture is a packed IYUV420 texture */
#define FU_ADM_FLAG_I420_TEXTURE 8
/*\brief Indicate that the input buffer is a packed IYUV420 buffer */
#define FU_ADM_FLAG_I420_BUFFER 16

#define FU_ADM_FALG_RGBA_BUFFER 128

typedef struct{
	void* p_NV21;//<the NV21 buffer
	int tex;//<the texture
	int flags;
}TAndroidDualMode;
/*\brief An I/O format where `ptr` points to a TNV12Buffer struct, which describes a YpCbCr8BiPlanar buffer. It matches the YUV camera formats on iOS. */
#define FU_FORMAT_NV12_BUFFER 8
typedef struct{
	void* p_Y;//<the Y plane base address
	void* p_CbCr;//<the CbCr plane base address
	int stride_Y;//<the Y plane bytes-per-row
	int stride_CbCr;//<the CbCr plane bytes-per-row
}TNV12Buffer;
/*\brief An internal input format for efficient iOS CVPixelBuffer handling where `ptr` points to a TIOSDualInput structure*/
#define FU_FORMAT_INTERNAL_IOS_DUAL_INPUT 9
#define FU_IDM_FORMAT_BGRA 0
#define FU_IDM_FORMAT_NV12 1
typedef struct{
	//members to be specified in the BGRA mode
	void* p_BGRA;//<the BGRA plane base address
	//members to be specified in the NV12 mode
	void* p_Y;//<the Y plane base address
	void* p_CbCr;//<the CbCr plane base address
	//members to be specified in the BGRA mode
	int stride_BGRA;//<the BGRA plane bytes-per-row
	//members to be specified in the NV12 mode
	int stride_Y;//<the Y plane bytes-per-row
	int stride_CbCr;//<the CbCr plane bytes-per-row
	//commom member
	int tex_handle;//<the GPU-side input, which has to be an RGBA texture
	/////////////////
	int format;//<FU_IDM_FORMAT_BGRA or FU_IDM_FORMAT_NV12
}TIOSDualInput;
/*\brief An internal output format for efficient iOS CVPixelBuffer handling where `ptr` points to a TIOSFBO structure*/
typedef struct{
	//we will reuse the FBO internally as an intermediate render target, so we need to know the texture
	//we expect a depth buffer to be bound to the FBO
	int fbo;//<the FBO to render onto
	int tex;//<the texture bound to that FBO
}TSPECFBO;
#define FU_FORMAT_GL_SPECIFIED_FRAMEBUFFER 10
////////////
/**\brief take a user-defined param and a a width / height pair and return a pointer to receive the image output*/
typedef void*(*PFRECEIVE_RESULT)(void* param,int w,int h);
typedef struct{
	unsigned char orientation;//<the target orientation and flags
	unsigned char version;//<version==0 for orientation only, set version to 1 if you want to read back anything
	unsigned short __padding;
	//version==1 members
	int image_output_mode;//<FU_FORMAT_BGRA_BUFFER, FU_FORMAT_RGBA_TEXTURE, FU_FORMAT_NV21_BUFFER, or FU_FORMAT_GL_CURRENT_FRAMEBUFFER for nothing at all
	PFRECEIVE_RESULT fcallback;//<the callback for receiving the image
	void* param;//<the user-defined param for the callback
}TGLRenderingDesc;

#define FU_FORMAT_AVATAR_INFO 12
typedef struct{	
	float* p_translation;	
	float* p_rotation;
	float* p_expression;
	float* rotation_mode;
	float* pupil_pos;
	int is_valid;
}TAvatarInfo;

typedef struct{
	void* in_ptr;
	int in_type;
	int out_w;
	int out_h;
	float view_0_ratio;
	int margin_in_pixel;
	int is_vertical;
	int is_image_first;
	int rotation_mode_before_crop;
	float crop_ratio_top;
}TSplitViewInfo;

#define FU_FORMAT_VOID 13

#define FU_ROTATION_MODE_0 0
#define FU_ROTATION_MODE_90 1
#define FU_ROTATION_MODE_180 2
#define FU_ROTATION_MODE_270 3


#ifdef __cplusplus
extern "C"{
#endif
/**
\brief Initialize and authenticate your SDK instance to the FaceUnity server, must be called exactly once before all other functions.
	The buffers should NEVER be freed while the other functions are still being called.
	You can call this function multiple times to "switch pointers".
\param v3data should point to contents of the "v3.bin" we provide
\param sz_v3data should point to num-of-bytes of the "v3.bin" we provide
\param ardata should be NULL
\param authdata is the pointer to the authentication data pack we provide. You must avoid storing the data in a file.
	Normally you can just `#include "authpack.h"` and put `g_auth_package` here.
\param sz_authdata is the authentication data size, we use plain int to avoid cross-language compilation issues.
	Normally you can just `#include "authpack.h"` and put `sizeof(g_auth_package)` here.
\return non-zero for success, zero for failure
*/
FUNAMA_API int fuSetup(float* v3data,int sz_v3data,float* ardata,void* authdata,int sz_authdata);

/**
\brief offline authentication
	Initialize and authenticate your SDK instance to the FaceUnity server, must be called exactly once before all other functions.
	The buffers should NEVER be freed while the other functions are still being called.
	You can call this function multiple times to "switch pointers".
\param v3data should point to contents of the "v3.bin" we provide
\param sz_v3data should point to num-of-bytes of the "v3.bin" we provide
\param ardata should be NULL
\param authdata is the pointer to the authentication data pack we provide. You must avoid storing the data in a file.
	Normally you can just `#include "authpack.h"` and put `g_auth_package` here.
\param sz_authdata is the authentication data size, we use plain int to avoid cross-language compilation issues.
	Normally you can just `#include "authpack.h"` and put `sizeof(g_auth_package)` here.
\param offline_bundle_ptr is the pointer to offline bundle from FaceUnity server
\param offline_bundle_sz is size of offline bundle
\return non-zero for success, zero for failure
*/
FUNAMA_API int fuSetupLocal(float* v3data, int sz_v3data,float* ardata,void* authdata,int sz_authdata,void** offline_bundle_ptr,int* offline_bundle_sz);

/**
\brief if nama is inited return 1,else return 0.
*/
FUNAMA_API int fuGetNamaInited();
/**
\brief Call this function when the GLES context has been lost and recreated.
	That isn't a normal thing, so this function could leak resources on each call.
*/
FUNAMA_API void fuOnDeviceLost();
/**
\brief Call this function to reset the face tracker on camera switches
*/
FUNAMA_API void fuOnCameraChange();

/**
\brief Load AI model data, to support tongue animation.
\param data - the pointer to AI model data 'ai_xxx.bundle', 
	which is along beside lib files in SDK package
\param sz - the data size, we use plain int to avoid cross-language compilation issues
\param type - define in FUAITYPE enumeration.
\return zero for failure, one for success.
*/
FUNAMA_API int fuLoadAIModelFromPackage(void* data,int sz,FUAITYPE type);

/**
\brief Release AI Model, when no more need some type of AI albility.
\param type - define in FUAITYPE enumeration.
\return zero for failure, one for success.
*/
FUNAMA_API int fuReleaseAIModel(FUAITYPE type);

/**
\brief Get AI Model load status
\param type - define in FUAITYPE enumeration.
\return zero for unloaded, one for loaded.
*/
FUNAMA_API int fuIsAIModelLoaded(FUAITYPE type);
/**
\brief Create an accessory item from a binary package, you can discard the data after the call.
	This function MUST be called in the same GLES context / thread as fuRenderItems.
\param data is the pointer to the data
\param sz is the data size, we use plain int to avoid cross-language compilation issues
\return an integer handle representing the item
*/
FUNAMA_API int fuCreateItemFromPackage(void* data,int sz);

FUNAMA_API int fuCreateLiteItemFromPackage(int handle, void* data, int sz);
/**
\brief Destroy an accessory item.
	This function MUST be called in the same GLES context / thread as the original fuCreateItemFromPackage.
\param item is the handle to be destroyed
*/
FUNAMA_API void fuDestroyItem(int item);
/**
\brief Destroy all accessory items ever created.
	This function MUST be called in the same GLES context / thread as the original fuCreateItemFromPackage.
*/
FUNAMA_API void fuDestroyAllItems();
/**
\brief Destroy all internal data, resources, threads, etc.
*/
FUNAMA_API void fuDestroyLibData();

/**
\brief Render a list of items on top of a GLES texture or a memory buffer.
	This function needs a GLES 2.0+ context.
\param texid specifies a GLES texture. Set it to 0u if you want to render to a memory buffer.
\param img specifies a memory buffer. Set it to NULL if you want to render to a texture.
	If img is non-NULL, it will be overwritten by the rendered image when fuRenderItems returns
\param w specifies the image width
\param h specifies the image height
\param frameid specifies the current frame id. 
	To get animated effects, please increase frame_id by 1 whenever you call this.
\param p_items points to the list of items
\param n_items is the number of items
\return a new GLES texture containing the rendered image in the texture mode
*/
FUNAMA_API int fuRenderItems(int texid,int* img,int w,int h,int frame_id, int* p_items,int n_items);
/**
\brief set crop state.
\param state is the Cropped switch
\return zero for closed, one for open 
*/

FUNAMA_API int fuSetCropState(int state);
/**
\brief Set the coordinates of the crop.
\param (x0,y0) is the coordinates of the starting point after cropping. (x0,y0) is (0,0) befor cropping
\param (x1,y1) is the coordinate of the end point after cropping. (x1,y1) is (imageWideth, imageHeight) before cropping
\return zero for failure, one for success 
*/
FUNAMA_API int fuSetCropFreePixel(int x0, int y0, int x1, int y1);
/**
\brief Generalized interface for rendering a list of items.
	This function needs a GLES 2.0+ context.
\param out_format is the output format
\param out_ptr receives the rendering result, which is either a GLuint texture handle or a memory buffer
	Note that in the texture cases, we will overwrite *out_ptr with a texture we generate.
\param in_format is the input format
\param in_ptr points to the input image, which is either a GLuint texture handle or a memory buffer
\param w specifies the image width
\param h specifies the image height
\param frameid specifies the current frame id. 
	To get animated effects, please increase frame_id by 1 whenever you call this.
\param p_items points to the list of items
\param n_items is the number of items
\return a GLuint texture handle containing the rendering result if out_format isn't FU_FORMAT_GL_CURRENT_FRAMEBUFFER
*/
FUNAMA_API int fuRenderItemsEx(
	int out_format,void* out_ptr,
	int in_format,void* in_ptr,
	int w,int h,int frame_id, int* p_items,int n_items);
	
/**
\brief Generalized interface for beautifying image.
	Disable face tracker and item rendering.
	This function needs a GLES 2.0+ context.
\param out_format is the output format
\param out_ptr receives the rendering result, which is either a GLuint texture handle or a memory buffer
	Note that in the texture cases, we will overwrite *out_ptr with a texture we generate.
\param in_format is the input format
\param in_ptr points to the input image, which is either a GLuint texture handle or a memory buffer
\param w specifies the image width
\param h specifies the image height
\param frameid specifies the current frame id. 
	To get animated effects, please increase frame_id by 1 whenever you call this.
\param p_items points to the list of items
\param n_items is the number of items
\return a GLuint texture handle containing the rendering result if out_format isn't FU_FORMAT_GL_CURRENT_FRAMEBUFFER
*/
FUNAMA_API int fuBeautifyImage(
	int out_format,void* out_ptr,
	int in_format,void* in_ptr,
	int w,int h,int frame_id, int* p_items,int n_items);

/**
\brief Generalized interface for tracking face.
	Disable item rendering and image beautifying.
	This function needs a GLES 2.0+ context.
\param out_format is the output format
\param out_ptr receives the rendering result, which is either a GLuint texture handle or a memory buffer
	Note that in the texture cases, we will overwrite *out_ptr with a texture we generate.
\param in_format is the input format
\param in_ptr points to the input image, which is either a GLuint texture handle or a memory buffer
\param w specifies the image width
\param h specifies the image height
\param frameid specifies the current frame id. 
	To get animated effects, please increase frame_id by 1 whenever you call this.
\param p_items points to the list of items
\param n_items is the number of items
\return a GLuint texture handle containing the rendering result if out_format isn't FU_FORMAT_GL_CURRENT_FRAMEBUFFER
*/
FUNAMA_API int fuTrackFace(int in_format,void* in_ptr,int w,int h);

FUNAMA_API int fuTrackFaceWithTongue(int in_format,void* in_ptr,int w,int h);
	
/**
\brief Generalized interface for rendering a list of items with extension.	
	This function needs a GLES 2.0+ context.
\param out_format is the output format
\param out_ptr receives the rendering result, which is either a GLuint texture handle or a memory buffer
	Note that in the texture cases, we will overwrite *out_ptr with a texture we generate.
\param in_format is the input format
\param in_ptr points to the input image, which is either a GLuint texture handle or a memory buffer
\param w specifies the image width
\param h specifies the image height
\param frameid specifies the current frame id. 
	To get animated effects, please increase frame_id by 1 whenever you call this.
\param p_items points to the list of items
\param n_items is the number of items
\param func_flag flags indicate all changable functionalities of render interface
\param p_masks indicates a list of masks for each item, bitwisely work on certain face
\return a GLuint texture handle containing the rendering result if out_format isn't FU_FORMAT_GL_CURRENT_FRAMEBUFFER
*/
FUNAMA_API int fuRenderItemsEx2(
	int out_format,void* out_ptr,
	int in_format,void* in_ptr,
	int w,int h,int frame_id, int* p_items,int n_items,
	int func_flag, void* p_item_masks);
	
FUNAMA_API int fuRenderBundles(
	int out_format,void* out_ptr,
	int in_format,void* in_ptr,
	int w,int h,int frame_id, int* p_items,int n_items);
	
FUNAMA_API int fuRenderBundlesSplitView(
	int out_format,void* out_ptr,
	int in_format,void* in_ptr,
	int w,int h,int frame_id, int* p_items,int n_items,
	int func_flag, void* p_item_masks,
	TSplitViewInfo* split_info);
	
FUNAMA_API int fuRotateImage(
	void* in_ptr, int in_format, int in_w,int in_h,
	int rotate_mode, int flip_x, int flip_y,
	void* out_ptr1, void* out_ptr2);
	
FUNAMA_API void fuSetInputCameraMatrix(int flip_x, int flip_y, int rotate_mode);
FUNAMA_API void fuSetOutputResolution(int w, int h);
	
#define NAMA_RENDER_FEATURE_TRACK_FACE 0x10
#define NAMA_RENDER_FEATURE_BEAUTIFY_IMAGE 0x20
#define NAMA_RENDER_FEATURE_RENDER 0x40
#define NAMA_RENDER_FEATURE_ADDITIONAL_DETECTOR 0x80
#define NAMA_RENDER_FEATURE_RENDER_ITEM 0x100
#define NAMA_RENDER_FEATURE_FULL (NAMA_RENDER_FEATURE_RENDER_ITEM | NAMA_RENDER_FEATURE_TRACK_FACE | NAMA_RENDER_FEATURE_BEAUTIFY_IMAGE | NAMA_RENDER_FEATURE_RENDER | NAMA_RENDER_FEATURE_ADDITIONAL_DETECTOR)
#define NAMA_RENDER_FEATURE_MASK 0xff0
#define NAMA_RENDER_OPTION_FLIP_X 0x1000
#define NAMA_RENDER_OPTION_FLIP_Y 0x2000
#define NAMA_NOCLEAR_CURRENT_FRAMEBUFFER 0x4000
#define NAMA_RENDER_OPTION_MASK 0xff000

/**************************************************************
The set / get functions do not make sense on their own. Refer to
the documentation of specific items for their get/set-able
parameters. Most items do not have any.
**************************************************************/

/**
\brief Set an item parameter to a double value
\param item specifies the item
\param name is the parameter name
\param value is the parameter value to be set
\return zero for failure, non-zero for success
*/
FUNAMA_API int fuItemSetParamd(int item,char* name,double value);
/**
\brief Set an item parameter to a double array
\param item specifies the item
\param name is the parameter name
\param value points to an array of doubles
\param n specifies the number of elements in value
\return zero for failure, non-zero for success
*/
FUNAMA_API int fuItemSetParamdv(int item,char* name,double* value,int n);
/**
\brief Set an item parameter to a u8 array
\param item specifies the item
\param name is the parameter name
\param value points to an array of doubles
\param n specifies the number of elements in value
\return zero for failure, non-zero for success
*/
FUNAMA_API int fuItemSetParamu8v(int item, char* name, void* value, int n);
/**
\brief Set an item parameter to a u64 value
\param item specifies the item
\param name is the parameter name
\param value is the parameter value to be set
\return zero for failure, non-zero for success
*/
FUNAMA_API int fuItemSetParamu64(int item,char* name, unsigned long long value);
/**
\brief create a texture for a rgba buffer and set tex as an item parameter
\param item specifies the item
\param name is the parameter name
\param value rgba buffer
\param width image width
\param height image height
\return zero for failure, non-zero for success
*/
FUNAMA_API int fuCreateTexForItem(int item, char* name, void* value, int width,int height);
/**
\brief delete the texture in item,only can be used to delete texutre create by fuCreateTexForItem
\param item specifies the item
\param name is the parameter name
\param value rgba buffer
\param width image width
\param height image height
\return zero for failure, non-zero for success
*/
FUNAMA_API int fuDeleteTexForItem(int item, char* name);


/**
\brief Set an item parameter to a string value
\param item specifies the item
\param name is the parameter name
\param value is the parameter value to be set
\return zero for failure, non-zero for success
*/
FUNAMA_API int fuItemSetParams(int item,char* name,char* value);
/**
\brief Get an item parameter as a double value
\param item specifies the item
\param name is the parameter name
\return double value of the parameter
*/
FUNAMA_API double fuItemGetParamd(int item,char* name);
FUNAMA_API int fuItemGetParamdv(int item, char* name, double* buf, int sz);
FUNAMA_API int fuItemGetParamfv(int item, char* name, float* buf, int sz);
/**
\brief Get an item parameter as a string
\param item specifies the item
\param name is the parameter name
\param buf receives the string value
\param sz is the number of bytes available at buf
\return the length of the string value, or -1 if the parameter is not a string.
*/
FUNAMA_API int fuItemGetParams(int item,char* name,char* buf,int sz);

FUNAMA_API int fuItemGetParamu8v(int item,char* name,char* buf,int sz);

/**
\brief Get an item parameter as a double array
\param item specifies the item
\param name is the parameter name
\param buf receives the double array value
\param n specifies the number of elements in value
\return the length of the double array value, or -1 if the parameter is not a double array.
*/
FUNAMA_API int fuItemGetParamdv(int item,char* name,double* buf,int n);
/**
\brief Get the face tracking status
\return The number of valid faces currently being tracked
*/
FUNAMA_API int fuIsTracking();
/**
\brief Set the default orientation for face detection. The correct orientation would make the initial detection much faster.
\param rmode is the default orientation to be set to, one of 0..3 should work.
*/
FUNAMA_API void fuSetDefaultOrientation(int rmode);
/**
\brief Set the maximum number of faces we track. The default value is 1.
\param n is the new maximum number of faces to track
\return The previous maximum number of faces tracked
*/
FUNAMA_API int fuSetMaxFaces(int n);

/**
\brief Get face info. Certificate aware interface.
\param face_id is the id of face, index is smaller than which is set in fuSetMaxFaces
	If this face_id is x, it means x-th face currently tracking
	To get a unique id for each face, use fuGetFaceIdentifier interface
\param name the name of certain face info
\param pret allocated memory space as container
\param num is number of float allocated in pret
	eg: 	  "landmarks" - 2D landmarks coordinates in image space - 75*2 float
			  "landmarks_ar" - 3D landmarks coordinates in camera space - 75*3 float
			  "eye_rotation" - eye rotation quaternion - 4 float - (Conversion between quaternions and Eular angles: https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles)
			  "translation" - 3D translation of face in camera space - 3 float
			  "rotation" - rotation quaternion - 4 float - (Conversion between quaternions and Eular angles: https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles)
			  "projection_matrix" - the transform matrix from camera space to image space - 16 float
			  "face_rect" - the rectangle of tracked face in image space, (xmin,ymin,xmax,ymax) - 4 float
			  "rotation_mode" - the relative orientaion of face agains phone, 0-3 - 1 float
			  "failure_rate" - the failure rate of face tracking, the less the more confident about tracking result - 1 float
\return 1 means successful fetch, container filled with info
	0 means failure, general failure is due to invalid face info
	other specific failure will print on the console
*/
FUNAMA_API int fuGetFaceInfo(int face_id, char* name, float* pret, int num);

/**
\brief Get the unique identifier for each face during current tracking
	Lost face tracking will change the identifier, even for a quick retrack
\param face_id is the id of face, index is smaller than which is set in fuSetMaxFaces
	If this face_id is x, it means x-th face currently tracking
\return the unique identifier for each face
*/	
FUNAMA_API int fuGetFaceIdentifier(int face_id);

/**
\ warning: deprecated API，use fuBindItems instead
\brief Bind items to an avatar, already bound items won't be unbound
\param avatar_item is the avatar item handle
\param p_items points to a list of item handles to be bound to the avatar
\param n_items is the number of item handles in p_items
\param p_contracts points to a list of contract handles for authorizing items
\param n_contracts is the number of contract handles in p_contracts
\return the number of items newly bound to the avatar
*/
FUNAMA_API int fuAvatarBindItems(int avatar_item, int* p_items,int n_items, int* p_contracts,int n_contracts);
/**
\warning: deprecated API，use fuUnindItems instead
\brief Unbind items from an avatar
\param avatar_item is the avatar item handle
\param p_items points to a list of item handles to be unbound from the avatar
\param n_items is the number of item handles in p_items
\return the number of items unbound from the avatar
*/
FUNAMA_API int fuAvatarUnbindItems(int avatar_item, int* p_items,int n_items);

//
/**
\brief Bind items to target item, target item act as a controller,target item should has 'OnBind' function, already bound items won't be unbound
\param item_src is the target item handle
\param p_items points to a list of item handles to be bound to the  target item 
\param n_items is the number of item handles in p_items
\return the number of items newly bound to the avatar
*/
FUNAMA_API int fuBindItems(int item_src, int* p_items,int n_items);
/**
\brief Unbind items from the target item
\param item_src is the target item handle
\param p_items points to a list of item handles to be unbound from the target item
\param n_items is the number of item handles in p_items
\return the number of items unbound from the target item
*/
FUNAMA_API int fuUnbindItems(int item_src, int* p_items,int n_items);
/**
\brief Unbind all items from the target item
\param item_src is the target item handle
\return the number of items unbound from the target item
*/
FUNAMA_API int fuUnbindAllItems(int item_src);

/**
\brief Get SDK version string, Major.Minor.Fix_ID
\return SDK version string in const char*
*/
FUNAMA_API const char* fuGetVersion();

/**
\brief Get SDK version Major bit, Major.Minor.Fix
\return SDK version Major bit in int
*/
FUNAMA_API int fuGetVersionMajor();

/**
\brief Get SDK version Minor bit, Major.Minor.Fix
\return SDK version Minor bit in int
*/
FUNAMA_API int fuGetVersionMinor();

/**
\brief Get SDK version Fix bit, Major.Minor.Fix
\return SDK version Fix bit in int
*/
FUNAMA_API int fuGetVersionFix();

/**
\brief Get system error, which causes system shutting down
\return System error code represents one or more errors	
	Error code can be checked against following bitmasks, non-zero result means certain error
	This interface is not a callback, needs to be called on every frame and check result, no cost
	Inside authentication error (NAMA_ERROR_BITMASK_AUTHENTICATION), meanings for each error code are listed below:
	1 failed to seed the RNG
	2 failed to parse the CA cert
	3 failed to connect to the server
	4 failed to configure TLS
	5 failed to parse the client cert
	6 failed to parse the client key
	7 failed to setup TLS
	8 failed to setup the server hostname
	9 TLS handshake failed
	10 TLS verification failed
	11 failed to send the request
	12 failed to read the response
	13 bad authentication response
	14 incomplete authentication palette info
	15 not inited yet
	16 failed to create a thread
	17 authentication package rejected
	18 void authentication data
	19 bad authentication package
	20 certificate expired
	21 invalid certificate
*/
#define NAMA_ERROR_BITMASK_AUTHENTICATION 	0xff
#define NAMA_ERROR_BITMASK_DEBUG_ITEM 		0x100
#define NAMA_ERROR_SEED_RNG_FAILURE 		1
#define NAMA_ERROR_PARSE_CA_CERT_FAILURE 	2
#define NAMA_ERROR_CONNECT_SERVER_FAILURE 	3
#define NAMA_ERROR_CONFIG_TLS_FAILURE 		4
#define NAMA_ERROR_PARSE_CLIENT_CERT_FAILURE 5
#define NAMA_ERROR_PARSE_CLIENT_KEY_FAILURE 6
#define NAMA_ERROR_SETUP_TLS_FAILURE 		7
#define NAMA_ERROR_SETUP_SERVER_FAILURE 	8
#define NAMA_ERROR_TLS_HANDSHAKE_FAILURE 	9
#define NAMA_ERROR_TLS_VERIFICATION_FAILURE 10
#define NAMA_ERROR_SEND_REQUEST_FAILURE 	11
#define NAMA_ERROR_READ_RESPONSE_FAILURE 	12
#define NAMA_ERROR_BAD_RESPONSE 			13
#define NAMA_ERROR_INCOMPLETE_PALETTE_INFO 	14
#define NAMA_ERROR_AUTH_NOT_INITED 			15
#define NAMA_ERROR_CREATE_THREAD_FAILURE 	16
#define NAMA_ERROR_AUTH_PACKAGE_REJECTED 	17
#define NAMA_ERROR_VOID_AUTH_DATA 			18
#define NAMA_ERROR_BAD_AUTH_PACKAGE			19
#define NAMA_ERROR_CERTIFICATE_EXPIRED 		20
#define NAMA_ERROR_INVALID_CERTIFICATE 		21
#define NAMA_ERROR_PARSE_SYSTEM_DATA_FAILURE 22
FUNAMA_API const int fuGetSystemError();

/**
\brief Interpret system error code
\param code - System error code returned by fuGetSystemError()
\return One error message from the code
*/
FUNAMA_API const char* fuGetSystemErrorString(int code);

/**
\brief Check whether an item is debug version
\param data - the pointer to the item data
\param sz - the data size, we use plain int to avoid cross-language compilation issues
\return 0 - normal item
		1 - debug item
		-1 - corrupted item data
*/
FUNAMA_API const int fuCheckDebugItem(void* data,int sz);

/**
\brief Get the expire time of an avatar item
\param data - the pointer to the item data, the item must be type of "p2a_avatar"
\param sz - the data size, we use plain int to avoid cross-language compilation issues
\return x - this avatar will expire in 'x' days
		-1 - invalid expire time, detail will be print on console
*/
FUNAMA_API const int fuGetAvatarExpireTime(void* data,int sz);

/**
\brief Control auto expression calibration
\param i - zero to disable calibration, non-zero to enable calibration
*/
FUNAMA_API void fuSetExpressionCalibration(int i);

/**
\brief Scale the rendering perspectivity (focal length, or FOV)
	Larger scale means less projection distortion
	This scale should better be tuned offline, and set it only once in runtime
\param scale - default is 1.f, keep perspectivity invariant
	<= 0.f would be treated as illegal input and discard	
*/
FUNAMA_API void fuSetFocalLengthScale(float scale);

/**
\warning: deprecated API
\brief Load extended AR data, which is required for high quality AR items
\param data - the pointer to the extended AR data
\param sz - the data size, we use plain int to avoid cross-language compilation issues
\return zero for failure, non-zero for success
*/
FUNAMA_API int fuLoadExtendedARData(void* data,int sz);

/**
\brief Load Tongue Detector data, to support tongue animation.
\param data - the pointer to tongue model data 'tongue.bundle', 
	which is along beside lib files in SDK package
\param sz - the data size, we use plain int to avoid cross-language compilation issues
\return zero for failure, one for success
*/
FUNAMA_API int fuLoadTongueModel(void* dat, int dat_sz);



FUNAMA_API void fuSetStrictTracking(int i);

/**
\brief Set the default rotationMode.
\param rotationMode is the default rotationMode to be set to, one of 0..3 should work.
*/
FUNAMA_API void fuSetDefaultRotationMode(int rotationMode);


/**
\brief Set the device's Orientation.
\param deviceOrientation is the device's runtime orientation, one of 0..3 should work.
*/
FUNAMA_API void fuSetDeviceOrientation(int deviceOrientation);

/**
\brief Get the current rotationMode.
\return the current rotationMode, one of 0..3 should work.
*/
FUNAMA_API int fuGetCurrentRotationMode();

/**
\brief Get certificate permission code for modules
\param i - get i-th code, currently available for 0 and 1
\return The permission code
*/
FUNAMA_API int fuGetModuleCode(int i);

/**
\brief Turn on or turn off Tongue Tracking, used in trackface.
\param enable > 0 means turning on, enable <= 0 means turning off
*/
FUNAMA_API int fuSetTongueTracking(int enable);

/**
\brief Turn on or turn off multisample anti-alising, msaa has an impact on performance.
\param samples > 0 means turning on, samples <= 0 means turning off, 0 by default. samples<=GL_MAX_SAMPLES(usually 4).
*/
FUNAMA_API int fuSetMultiSamples(int samples);

/**
\brief Turn on or turn off async track face
\param enable > 0 means turning on, enable <= 0 means turning off
*/
FUNAMA_API int fuSetASYNCTrackFace(int enable);

/**
\brief Clear Physics World
\return 0 means physics disabled and no need to clear,1 means cleared successfully
*/
FUNAMA_API int fuClearPhysics();

/**
\brief Set a face detector parameter.
\param detector is the detector context, currently it is allowed to set to NULL, i.e., globally set all contexts.
\param name is the parameter name, it can be:
	"use_new_cnn_detection": 1 if the new cnn-based detection method is used, 0 else
	"other_face_detection_frame_step": if one face already exists, then we detect other faces not each frame, but with a step,default 10 frames
	if use_new_cnn_detection == 1, then
		"min_facesize_small", int[default=18]: minimum size to detect a small face; must be called **BEFORE** fuSetup
		"min_facesize_big", int[default=27]: minimum size to detect a big face; must be called **BEFORE** fuSetup
		"small_face_frame_step", int[default=5]: the frame step to detect a small face; it is time cost, thus we do not detect each frame
		"use_cross_frame_speedup", int[default=0]: perform a half-cnn inference each frame to speedup
		"enable_large_pose_detection", int[default=1]: enable rotated face detection up to 45^deg roll in each rotation mode.
	else
		"scaling_factor": the scaling across image pyramids, default 1.2f
		"step_size": the step of each sliding window, default 2.f
		"size_min": minimal face supported on 640x480 image, default 50.f
		"size_max": maximal face supported on 640x480 image, default is a large value
		"min_neighbors": algorithm internal, default 3.f
		"min_required_variance": algorithm internal, default 15.f
\param value points to the new parameter value, e.g., 
	float scaling_factor=1.2f;
	dde_facedet_set(ctx, "scaling_factor", &scaling_factor);
	float size_min=100.f;
	dde_facedet_set(ctx, "size_min", &size_min);
*/
FUNAMA_API int fuSetFaceDetParam(char* name, float* pvalue);

/**
\brief Set the global face tracker parameter.
\param name is the parameter name, it can be:
	"mouth_expression_more_flexible": \in [0, 1], default=0; additionally make mouth expression more flexible.
	"expression_calibration_strength": \in [0, 1], default=0.2; strenght of expression soft calibration.
\param value points to the new parameter value, e.g., 
	float mouth_expression_more_flexible=0.6f;
	dde_facetrack_set("mouth_expression_more_flexible", &mouth_expression_more_flexible);
*/
FUNAMA_API int fuSetFaceTrackParam(char* name, float* pvalue);

/**
\brief if one face is detected, we may want to detect other faces at lower frequency
		this method set the frame step
\param n_frame_step we detect additional faces each n frames.
\returns the frame step after set
*/
FUNAMA_API int fuSetOtherFaceDetStep(int n_frame_step);

/*------------------------------------------*/
/*************** Deprecated *****************/
/*------------------------------------------*/

/**
\brief Set the quality-performance tradeoff. 
\param quality is the new quality value. 
       It's a floating point number between 0 and 1.
       Use 0 for maximum performance and 1 for maximum quality.
       The default quality is 1 (maximum quality).
*/
FUNAMA_API void fuSetQualityTradeoff(float quality);
/**
\brief Turn off the camera
*/
FUNAMA_API void fuTurnOffCamera();


FUNAMA_API void fuGetTickData(float* buf,int n);
/**
\brief Generalized interface for rendering a list of items.
	This function needs a GLES 2.0+ context.
\param out_format is the output format
\param out_ptr receives the rendering result, which is either a GLuint texture handle or a memory buffer
	Note that in the texture cases, we will overwrite *out_ptr with a texture we generate.
\param in_format is the input format
\param in_ptr points to the input image, which is either a GLuint texture handle or a memory buffer
\param w specifies the image width
\param h specifies the image height
\param frameid specifies the current frame id. 
	To get animated effects, please increase frame_id by 1 whenever you call this.
\param p_items points to the list of items
\param n_items is the number of items
\param p_masks indicates a list of masks for each item, bitwisely work on certain face
\return a GLuint texture handle containing the rendering result if out_format isn't FU_FORMAT_GL_CURRENT_FRAMEBUFFER
*/
FUNAMA_API int fuRenderItemsMasked(
	int out_format,void* out_ptr,
	int in_format,void* in_ptr,
	int w,int h,int frame_id, int* p_items,int n_items, int* p_masks);
/**
\brief Get the camera image size
\param pret points to two integers, which receive the size
*/
FUNAMA_API void fuGetCameraImageSize(int* pret);

FUNAMA_API int fuHasFace();


/**
\brief Create a 3D human tracker
\param data the binary bundle data
\param sz bytes of data
\return the pointer of the created tracker
*/
void* fu3DBodyTrackerCreate(void* data, int sz);

/**
\brief Destroy a 3D human tracker
\param model_ptr the pointer of the created tracker
*/
void fu3DBodyTrackerDestroy(void* model_ptr);

/**
\brief Run a 3D human tracker
\param model_ptr the pointer of the created tracker
\param human_handle a specified human, related to resource management
\param img input image pointer, data type must be byte
\param w input image width
\param h input image height
\param fu_image_format FU_FORMAT_*_BUFFER
\param rotation_mode w.r.t to rotation the the camera view, 0=0^deg, 1=90^deg, 2=180^deg, 3=270^deg
\return internal status
*/
int fu3DBodyTrackerRun(void* model_ptr, int human_handle, void* img, int w, int h, int fu_image_format, int rotation_mode);




/**
\brief Create a face capture manager
\param data the binary bundle data
\param sz bytes of data
\return the pointer of the created capture manager
*/
void* fuFaceCaptureCreate(void* data, int sz);;

/**
\brief Destroy a face capture manager
\param model_ptr the pointer of the created capture manager
*/
int fuFaceCaptureDestory(void* model_ptr);


/**
\brief set scene for face capture manager
\param model_ptr the pointer of the created capture manager
*/
int fuFaceCaptureSetScene(void* model_ptr,int scene_type);

/**
\brief set box of face for face capture manager
\param model_ptr the pointer of the created capture manager
*/
int fuFaceCaptureSetBBOX(void* model_ptr,int cx, int cy, int sx, int sy);


/**
\brief Reset Tracking
\param model_ptr the pointer of the created capture manager
*/
int fuFaceCaptureReset(void* model_ptr);



/**
\brief Run face capturing
\param manager_ptr_addr the pointer of the capture manager
\param img input image pointer, data type must be byte
\param w input image width
\param h input image height
\param fu_image_format FU_FORMAT_*_BUFFER
\param rotation_mode w.r.t to rotation the the camera view, 0=0^deg, 1=90^deg, 2=180^deg, 3=270^deg
\return whether the current frame is valid for tracking
*/
int fuFaceCaptureProcessFrame(void* manager_ptr_addr,
							void* image_data,
							int image_w,
							int image_h,
							int fu_image_format,
							int rotate_mode);


/**
\brief get landmarks result
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param size_n  the size of result
*/
float* fuFaceCaptureGetResultLandmarks(void*  manager_ptr_addr,
									int face_n,
									int*  size_n);


/**
\brief get identity result
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param size_n  the size of result
*/
float* fuFaceCaptureGetResultIdentity(void*  manager_ptr_addr,
									int face_n,
									int*  size_n);


/**
\brief get expression result
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param size_n  the size of result
*/
float* fuFaceCaptureGetResultExpression(void*  manager_ptr_addr,
									int face_n,
									int*  size_n);

/**
\brief get rotation result
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param size_n  the size of result
*/
float* fuFaceCaptureGetResultRotation(void*  manager_ptr_addr,
									int face_n,
									int*  size_n);

/**
\brief get eyes' rotation result
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param size_n  the size of result
*/
float* fuFaceCaptureGetResultEyesRotation(void*  manager_ptr_addr,
									int face_n,
									int*  size_n);


/**
\brief get translation result
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param size_n  the size of result
*/
float* fuFaceCaptureGetResultTranslation(void*  manager_ptr_addr,
									int face_n,
									int* size_n);


/**
\brief get is face result
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param size_n  the size of result
*/
int fuFaceCaptureGetResultIsFace(void*  manager_ptr_addr,
									int face_n);

/**
\brief get face id result
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param output_data  the space to save result
*/
int fuFaceCaptureGetResultFaceID(void*  manager_ptr_addr,
									int face_n);


/**
\brief get focal length result
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param output_data  the space to save result
*/
float fuFaceCaptureGetResultFocalLength(void* manager_ptr_addr);


/**
\brief get face num result
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param output_data  the space to save result
*/
int fuFaceCaptureGetResultFaceNum(void* manager_ptr_addr);


/**
\brief get tongue score
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param output_data  the space to save result
*/
float fuFaceCaptureGetResultTongueScore(void* manager_ptr_addr,int face_n);


/**
\brief get face score
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param output_data  the space to save result
*/
float fuFaceCaptureGetResultFaceScore(void* manager_ptr_addr,int face_n);



/**
\brief get tongue class
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param output_data  the space to save result
*/
int fuFaceCaptureGetResultTongueClass(void* manager_ptr_addr,int face_n);


/**
\brief get tongue expression result
\param manager_ptr_addr the pointer of the capture manager
\param face_n  the index of captured face
\param size_n  the size of result
*/
float* fuFaceCaptureGetResultTongueExp(void*  manager_ptr_addr,
									int face_n,
									int* size_n);


#ifdef __cplusplus
}
#endif

#endif
