import { Component, OnInit, Input, OnDestroy, OnChanges } from '@angular/core';
import { Router, NavigationEnd, NavigationStart, NavigationCancel, NavigationError } from '@angular/router';
import { Observable, Subscription } from 'rxjs';
import { filter } from 'rxjs/operators';

import { Site } from './site';
import { IsLoadingService } from './is-loading.service';
import { AuthorizationService } from './authorization.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit, OnDestroy {
  title = 'loba';
  refresh = false;
  isLoading: Observable<boolean>;

  constructor(
    private isLoadingService: IsLoadingService,
    private authorizationService: AuthorizationService,
    private router: Router) {
      this.loggedInSubscription = this.authorizationService.isLoggedIn$.subscribe(
        loggedIn => {
          this.isLoggedIn = loggedIn;
      });
  }

  @Input() isLoggedIn: boolean;
  loggedInSubscription: Subscription

  ngOnInit(): void {
    this.authorizationService.fetchToken();
    this.isLoading = this.isLoadingService.isLoading$();

    this.router.events
      .pipe(
        filter(
          event =>
            event instanceof NavigationStart ||
            event instanceof NavigationEnd ||
            event instanceof NavigationCancel ||
            event instanceof NavigationError,
        ),
      )
      .subscribe(event => {
        // If it's the start of navigation, `add()` a loading indicator
        if (event instanceof NavigationStart) {
          this.isLoadingService.add();
          return;
        }

        // Else navigation has ended, so `remove()` a loading indicator
        this.isLoadingService.remove();
      });
  }

  onActivate(componentReference: any) {
    if (componentReference.siteUpdated !== undefined) {
      //Below will subscribe to the siteUpdated emitter
      componentReference.siteUpdated.subscribe((site: Site) => {
        this.refresh = (this.refresh == false);
        this.router.navigateByUrl(`/site/${site.domain}`);
      });
    }

    if (componentReference.siteRemoved !== undefined) {
      componentReference.siteRemoved.subscribe((site: Site) => {
        this.refresh = (this.refresh == false);
        this.router.navigateByUrl(``);
      });
    }
  }

  ngOnDestroy(): void {
    this.loggedInSubscription.unsubscribe();
  }
}
