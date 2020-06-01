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
import { NgxFitTextModule } from 'ngx-fit-text';

// routers
import { AppRoutingModule } from './app-routing.module';

// interceptors
import { HttpInterceptorProviders} from './http-interceptors/index';

// components
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
    RemoveSiteConfirmComponent
  ],
  imports: [
    FormsModule,
    ReactiveFormsModule,
    BrowserModule,
    HttpClientModule,
    AppRoutingModule,
    NgxFitTextModule.forRoot(),
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
    HttpInterceptorProviders,
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
