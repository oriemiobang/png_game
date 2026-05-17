import { Body, Controller, Post, HttpException, HttpStatus } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('signup')
  async signUp(@Body() body: any) {
    if (!body.email || !body.password || !body.name) {
      throw new HttpException('Email, password, and name are required', HttpStatus.BAD_REQUEST);
    }
    return this.authService.signUp(body.email, body.password, body.name);
  }

  @Post('signin')
  async signIn(@Body() body: any) {
    if (!body.email || !body.password) {
      throw new HttpException('Email and password are required', HttpStatus.BAD_REQUEST);
    }
    return this.authService.signIn(body.email, body.password);
  }

  @Post('google')
  async googleSignIn(@Body() body: any) {
    if (!body.idToken) {
      throw new HttpException('Google ID token is required', HttpStatus.BAD_REQUEST);
    }
    return this.authService.verifyGoogleToken(body.idToken);
  }
}
