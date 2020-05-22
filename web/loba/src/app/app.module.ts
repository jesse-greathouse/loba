import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule } from '@angular/forms';

import { HttpInterceptorProviders} from './http-interceptors/index';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { ToolbarComponent } from './toolbar/toolbar.component';
import { FooterComponent } from './footer/footer.component';
import { TerminalComponent } from './terminal/terminal.component';
import { LinksComponent } from './links/links.component';
import { SitesComponent } from './sites/sites.component';
import { MessagesComponent } from './messages/messages.component';
import { SiteDetailComponent } from './site-detail/site-detail.component';

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
    AppRoutingModule,
    HttpClientModule
  ],
  providers: [
    HttpInterceptorProviders,
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
