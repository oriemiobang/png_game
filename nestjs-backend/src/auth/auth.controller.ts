import { Body, Controller, Get, Post, Patch, HttpException, HttpStatus, Req, Res, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthGuard } from '@nestjs/passport';
import { ThrottlerGuard } from '@nestjs/throttler';

@UseGuards(ThrottlerGuard)
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

  @Get('google')
  @UseGuards(AuthGuard('google'))
  async googleAuth(@Req() req: any) {
    // Initiates the Google OAuth flow
  }

  @Get('google/callback')
  @UseGuards(AuthGuard('google'))
  async googleAuthRedirect(@Req() req: any, @Res() res: any) {
    const { access_token } = await this.authService.validateOAuthLogin(req.user);
    // Redirect back to the app using the custom url scheme
    return res.redirect(`pnggame://callback?access_token=${access_token}`);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('me/stats')
  async myStats(@Req() req: any) {
    return this.authService.getMyStats(req.user.userId);
  }

  @Get('leaderboard')
  async getLeaderboard() {
    return this.authService.getLeaderboard();
  }

  @UseGuards(AuthGuard('jwt'))
  @Patch('me/fcm-token')
  async updateFcmToken(@Req() req: any, @Body('fcmToken') fcmToken: string) {
    return this.authService.updateFcmToken(req.user.userId, fcmToken);
  }
}
