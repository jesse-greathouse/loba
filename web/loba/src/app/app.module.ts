// Angular
import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';

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
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

@NgModule({
  declarations: [
    AppComponent,
    ToolbarComponent,
    FooterComponent,
    TerminalComponent,
    LinksComponent,
    SitesComponent,
    MessagesComponent,
    SiteDetailComponent
  ],
  imports: [
    FormsModule,
    BrowserModule,
    HttpClientModule,
    AppRoutingModule,
    NgxFitTextModule.forRoot(),
    BrowserAnimationsModule
  ],
  providers: [
    HttpInterceptorProviders,
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
