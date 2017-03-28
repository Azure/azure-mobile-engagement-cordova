declare namespace EngagementPlugin {
    interface Engagement {
        /**
         * Register the application to receive push notification
         * @param onOpenURL          The function to be called when an application specific URL is triggered
         * @param onDataPushReceived The function handler to receive the data push
         * @param success:          Optional callback invoked if the initialize operation succeeded
         * @param failure:          Optional callback invoked in case of an error
         *
         */
        initializeReach(
            onOpenURL: (url: string) => void,
            onDataPushReceived: (category: string, body: string) => void,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Start a new activity  with the corresponding extra infos object
         * @param activityName The name of the activity
         * @param extraInfos   A json object containing the extra infos attached to this activity
         * @param success:     Optional callback invoked if the start activity operation succeeded
         * @param failure:     Optional callback invoked in case of an error
         *
         */
        startActivity(
            activityName: string,
            extraInfos: any,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Ends the current Actvity. Would trigger a new session on the next startActivity
         * @param success: Optional callback invoked if the end activity operation succeeded
         * @param failure: Optional callback invoked in case of an error
         *
         */
        endActivity(
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Send an event  with the corresponding extra infos object.
         * @param eventName  The name of the event
         * @param extraInfos A json object containing the extra infos attached to this activity
         * @param success:   Optional callback invoked if the operation send event succeeded
         * @param failure:   Optional callback invoked in case of an error
         *
         */
        sendEvent(
            eventName: string,
            extraInfos: any,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Start an new job  with the corresponding extra infos object
         * @param jobName     The name of the job
         * @param extraInfos  A json object containing the extra infos attached to this activity
         * @param success:    Optional callback invoked if the operation start job succeeded
         * @param failure:    Optional callback invoked in case of an error
         *
         */
        startJob(
            jobName: string,
            extraInfos: any,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * End a job previously created by startJob
         * @param jobName  The name of the job
         * @param success: Optional callback invoked if the operation end job succeeded
         * @param failure: Optional callback invoked in case of an error
         *
         */
        endJob(
            jobName: string,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Send a session event
         * @param eventName The name of the event
         * @param extraInfos A json object containing the extra infos attached to this activity
         * @param success:   Optional callback invoked if the operation send session event succeeded
         * @param failure:   Optional callback invoked in case of an error
         *
         */
        sendSessionEvent(
            eventName: string,
            extraInfos: any,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Send a session error
         * @param error      Error string
         * @param extraInfos A json object containing the extra infos attached to this activity
         * @param success:   Optional callback invoked if the operation send session error succeeded
         * @param failure:   Optional callback invoked in case of an error
         *
         */
        sendSessionError(
            error: string,
            extraInfos: any,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Send a error
         * @param error      Error string
         * @param extraInfos A json object containing the extra infos attached to this activity
         * @param success:   Optional callback invoked if the operation send error succeeded
         * @param failure:   Optional callback invoked in case of an error
         *
         */
        sendError(
            error: string,
            extraInfos: any,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Send a job event
         * @param eventName  The name of the event
         * @param jobName    The name of the job
         * @param extraInfos A json object containing the extra infos attached to this activity
         * @param success:   Optional callback invoked if the operation send job event succeeded
         * @param failure:   Optional callback invoked in case of an error
         *
         */
        sendJobEvent(
            eventName: string,
            jobName: string,
            extraInfos: any,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Send a job error
         * @param error      Error string
         * @param jobName    The name of the job
         * @param extraInfos A json object containing the extra infos attached to this activity
         * @param success:   Optional callback invoked if the operation send job error succeeded
         * @param failure:   Optional callback invoked in case of an error
         *
         */
        sendJobError(
            error: string,
            jobName: string,
            extraInfos: any,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Send App Infos atttached to the currente device
         * @param appInfos The json object containing the app infos to be sent
         * @param success: Optional callback invoked if the operation send app info succeeded
         * @param failure: Optional callback invoked in case of an error
         *
         */
        sendAppInfo(
            appInfos: Object,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Report crashes manually (Windows Only)
         * @param crashId   The crashid argument is a string used to identify the type of the crash
         * @param crash     The stack trace of the crash as a string
         * @param success:  Optional callback invoked if the operation send crash succeeded
         * @param failure:  Optional callback invoked in case of an error
         *
         */
        sendCrash(
            crashId: string,
            crash: string,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Active or deactivate the agent
         * @param enabled  The status of the agent
         * @param success: Optional callback invoked if the operation set enabled succeeded
         * @param failure: Optional callback invoked in case of an error
         *
         */
        setEnabled(
            enabled: boolean,
            success?: () => void,
            failure?: (error: string) => void): void;

        /**
         * Returns the status of the agent
         * @param callback  Callback that is passed the status of the agent
         * @param failure: Optional callback invoked in case of an error
         *
         */
        isEnabled(
            callback: (enabled: boolean ) => void,
            failure?: (error: string) => void): void;

        /**
         * Allow the user to autorize the permissions needed for the proper execution of the AZME plugin.
         * By default, there's no need for a additional permissions, but if you've enabled the location reporting, this function must be called
         * to let the user allow the location based permissions (`ACCESSFINELOCATION` and/or `ACCESSCOARSELOCATION`)
         * @param callback  Success callback that is passed the list of permissions that have been asked, ans whether the user has allowed them or not
         * @param failure: Optional callback invoked in case of an error
         *
         */
        requestPermissions(
            callback: (ret: Object) => void,
            failure?: (error: string) => void): void;

        /**
         * Returns information about the AZME plugin.
         * @param statusCallback The handler that is passed a json object containing information about the AZME library
         * @param failure:       Optional callback invoked in case of an error
         *
         */
        getStatus(
            statusCallback: (info: StatusInfo) => void,
            failure?: (error: string) => void): void;
    }

    /** A StatusInfo object is passed to the success callback of the getStatus method **/
    interface StatusInfo {
        /** the version number of the AZME native SDK */
        nativeVesrion: string,
        /** the version number of the Cordova plugin */
        pluginVersion: string,
        /** the deviceId as defined by AZME */
        deviceId: string,
        /** if the plugin has been enabled (iOS only) */
        isEnabled: boolean,
        /**if the user has alredy accepted to receive notifications (iOS only) */
        notificationGranted: boolean
    }
}

interface Window {
    Engagement: EngagementPlugin.Engagement;
}

declare var Engagement: EngagementPlugin.Engagement;
