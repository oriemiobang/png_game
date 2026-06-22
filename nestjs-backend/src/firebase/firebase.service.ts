import { Injectable, Logger } from '@nestjs/common';
import { initializeApp, getApps } from 'firebase-admin/app';
import { getMessaging, Message } from 'firebase-admin/messaging';

@Injectable()
export class FirebaseService {
  private readonly logger = new Logger(FirebaseService.name);
  private initialized = false;

  constructor() {
    try {
      if (!getApps().length) {
        initializeApp(); // Will use GOOGLE_APPLICATION_CREDENTIALS or default ADC
        this.initialized = true;
        this.logger.log('Firebase Admin SDK initialized successfully.');
      } else {
        this.initialized = true;
      }
    } catch (error) {
      this.logger.warn('Failed to initialize Firebase Admin SDK. Push notifications will be disabled.', error.message);
    }
  }

  async sendPushNotification(token: string, title: string, body: string, data?: Record<string, string>) {
    if (!this.initialized || !token) return;

    try {
      const message: Message = {
        token,
        notification: {
          title,
          body,
        },
        data,
      };
      
      const response = await getMessaging().send(message);
      this.logger.debug(`Successfully sent FCM message: ${response}`);
    } catch (error) {
      this.logger.error('Error sending FCM message:', error.message);
    }
  }
}
