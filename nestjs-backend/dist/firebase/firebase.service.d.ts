export declare class FirebaseService {
    private readonly logger;
    private initialized;
    constructor();
    sendPushNotification(token: string, title: string, body: string, data?: Record<string, string>): Promise<void>;
}
