#include <android/native_activity.h>
#include <android/log.h>
#include <stdlib.h>
#include <jni.h>

static void onDestroy(ANativeActivity *activity) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Destroy");
}

static void onStart(ANativeActivity *activity) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Start");
}

static void onResume(ANativeActivity *activity) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Resume");
}

static void *onSaveInstanceState(ANativeActivity *activity, size_t *size) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Save instance state");
	*size = 0;
	return NULL;
}

static void onPause(ANativeActivity *activity) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Pause");
}

static void onStop(ANativeActivity *activity) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Stop");
}

static void onConfigurationChanged(ANativeActivity *activity) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Configuration changed");
}

static void onLowMemory(ANativeActivity *activity) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Low memory");
}

static void onWindowFocusChanged(ANativeActivity *activity, int focused) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Window focus changed");
}

static void onNativeWindowCreated(ANativeActivity *activity, ANativeWindow *window) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Native window created");
}

static void onNativeWindowDestroyed(ANativeActivity *activity, ANativeWindow *window) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Native window destroyed");
}

static void onInputQueueCreated(ANativeActivity *activity, AInputQueue *queue) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Input queue created");
}

static void onInputQueueDestroyed(ANativeActivity *activity, AInputQueue *queue) {
	__android_log_print(ANDROID_LOG_INFO, "Event", "Input queue destroyed");
}

JNIEXPORT void ANativeActivity_onCreate(ANativeActivity *activity, void *saved_state, size_t saved_state_size) {

	__android_log_print(ANDROID_LOG_INFO, "Event", "Create activity");

	activity->callbacks->onDestroy = onDestroy;
	activity->callbacks->onStart = onStart;
	activity->callbacks->onResume = onResume;
	activity->callbacks->onSaveInstanceState = onSaveInstanceState;
	activity->callbacks->onPause = onPause;
	activity->callbacks->onStop = onStop;
	activity->callbacks->onConfigurationChanged = onConfigurationChanged;
	activity->callbacks->onLowMemory = onLowMemory;
	activity->callbacks->onWindowFocusChanged = onWindowFocusChanged;
	activity->callbacks->onNativeWindowCreated = onNativeWindowCreated;
	activity->callbacks->onNativeWindowDestroyed = onNativeWindowDestroyed;
	activity->callbacks->onInputQueueCreated = onInputQueueCreated;
	activity->callbacks->onInputQueueDestroyed = onInputQueueDestroyed;
}
