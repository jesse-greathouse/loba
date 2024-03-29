// Angular
import { NgModule } from '@angular/core';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';

// Anguar Material
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatMenuModule } from '@angular/material/menu';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatButtonToggleModule } from '@angular/material/button-toggle';
import { MatInputModule } from '@angular/material/input';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatSelectModule } from '@angular/material/select';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatDialogModule } from '@angular/material/dialog';

// Platform Browser
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

// 3rd party libraries
import {AngularFittextModule} from 'angular-fittext';
import { SocialLoginModule, SocialAuthServiceConfig } from "angularx-social-login";
import { GoogleLoginProvider} from "angularx-social-login";

// routers
import { AppRoutingModule } from './app-routing.module';

// interceptors
import { HttpInterceptorProviders} from './http-interceptors/index';

// components
import { AppConfig } from './app.config';
import { AppComponent } from './app.component';
import { ToolbarComponent } from './toolbar/toolbar.component';
import { FooterComponent } from './footer/footer.component';
import { TerminalComponent } from './terminal/terminal.component';
import { LinksComponent } from './links/links.component';
import { SitesComponent } from './sites/sites.component';
import { MessagesComponent } from './messages/messages.component';
import { SiteDetailComponent } from './site-detail/site-detail.component';
import { UpstreamComponent } from './upstream/upstream.component';
import { MethodComponent } from './method/method.component';
import { ServerComponent } from './server/server.component';
import { RemoveServerConfirmComponent } from './remove-server-confirm/remove-server-confirm.component';
import { RemoveSiteConfirmComponent } from './remove-site-confirm/remove-site-confirm.component';
import { CertificateComponent } from './certificate/certificate.component';
import { RemoveCertificateConfirmComponent } from './remove-certificate-confirm/remove-certificate-confirm.component';
import { RemoveKeyConfirmComponent } from './remove-key-confirm/remove-key-confirm.component';
import { SelfSignedConfirmComponent } from './self-signed-confirm/self-signed-confirm.component';
import { LoginComponent } from './login/login.component';
import { UserAdminComponent } from './user-admin/user-admin.component';
import { UserComponent } from './user/user.component';
import { RemoveUserConfirmComponent } from './remove-user-confirm/remove-user-confirm.component';


// Create a new AuthServiceConfig object to set up OAuth2
// Use your Client ID in the GoogleLoginProvider()
let appConfig: AppConfig = {
  // @ts-ignore TOKEN added to window in index.html
  token: window.TOKEN,
  // @ts-ignore PAGEID added to window in index.html
  pageId: window.PAGEID,
};

// Function to retrieve the appConfig object
export function provideAppServiceConfig() {
  return appConfig;
}

@NgModule({
  declarations: [
    AppComponent,
    ToolbarComponent,
    FooterComponent,
    TerminalComponent,
    LinksComponent,
    SitesComponent,
    MessagesComponent,
    SiteDetailComponent,
    UpstreamComponent,
    MethodComponent,
    ServerComponent,
    RemoveServerConfirmComponent,
    RemoveSiteConfirmComponent,
    CertificateComponent,
    RemoveCertificateConfirmComponent,
    RemoveKeyConfirmComponent,
    SelfSignedConfirmComponent,
    LoginComponent,
    UserAdminComponent,
    UserComponent,
    RemoveUserConfirmComponent
  ],
  imports: [
    FormsModule,
    ReactiveFormsModule,
    BrowserModule,
    HttpClientModule,
    AppRoutingModule,
    AngularFittextModule,
    BrowserAnimationsModule,
    MatSidenavModule,
    MatToolbarModule,
    MatListModule,
    MatMenuModule,
    MatIconModule,
    MatInputModule,
    MatButtonModule,
    MatButtonToggleModule,
    MatProgressSpinnerModule,
    MatSelectModule,
    MatCheckboxModule,
    MatExpansionModule,
    MatDialogModule
  ],
  exports: [
    MatSidenavModule,
    MatToolbarModule,
    MatListModule,
    MatMenuModule,
    MatIconModule,
    MatInputModule,
    MatButtonModule,
    MatButtonToggleModule,
    MatProgressSpinnerModule,
    MatSnackBarModule,
    MatSelectModule,
    MatCheckboxModule,
    MatExpansionModule,
    MatDialogModule
  ],
  providers: [
    {
      provide: 'SocialAuthServiceConfig',
      useValue: {
        autoLogin: false,
        providers: [
          {
            id: GoogleLoginProvider.PROVIDER_ID,
            provider: new GoogleLoginProvider(
              'clientId'
            )
          }
        ]
      } as SocialAuthServiceConfig,
    },
    {
      provide: AppConfig,
      useFactory: provideAppServiceConfig
    },
    HttpInterceptorProviders,
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
