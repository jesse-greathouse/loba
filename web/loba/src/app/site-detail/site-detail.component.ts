import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';
import { ActivatedRoute, Router, NavigationEnd } from '@angular/router';
import { Subscription } from 'rxjs';

import { Site } from '../site';
import { SiteService } from '../site.service';
import { IsLoadingService } from '../is-loading.service';
import { RemoveSiteConfirmComponent } from '../remove-site-confirm/remove-site-confirm.component'
import { MatDialog } from '@angular/material/dialog';

@Component({
  host: {
    class:'content-wrapper',
  },
  selector: 'app-site-detail',
  templateUrl: './site-detail.component.html',
  styleUrls: ['./site-detail.component.css']
})
export class SiteDetailComponent implements OnInit {

  @Input() site: Site;
  @Output() siteUpdated: EventEmitter<Site> = new EventEmitter();
  @Output() siteRemoved: EventEmitter<Site> = new EventEmitter();

  constructor(
    public dialog: MatDialog,
    private siteService: SiteService,
    private route: ActivatedRoute,
    private isLoadingService: IsLoadingService,
    private router: Router) {

      this.isLoadingSubscription = this.isLoadingService.isLoading$()
        .subscribe(isLoading => {
            this.isLoading = isLoading;
        });

      this.router.events.subscribe(event => {
        if (event instanceof NavigationEnd) {
          this.loadSiteDetail();
        }
      });
  }

  @Input() isLoading: boolean;
  isLoadingSubscription: Subscription;

  ngOnInit(): void {
  }

  focusOut(): void {
    this.save();
  }

  loadSiteDetail(): void {
    const domain = this.route.snapshot.paramMap.get('domain');
    // If a domain is requested and it's not the same as the currently diplayed domain
    if (domain && 
        (typeof this.site === 'undefined' || domain !== this.site.domain)) {
      this.getSiteByDomain(domain);
    }
  }

  getSiteByDomain(domain: string): void {
    this.isLoadingService.add();
    this.siteService.getSiteByDomain(domain)
      .subscribe(site => {
        this.site = site;
        this.isLoadingService.remove();
      });
  }

  getSite(id: number): void {
    this.isLoadingService.add();
    this.siteService.getSite(id)
      .subscribe(site => {
        this.site = site;
        this.isLoadingService.remove();
      });
  }

  save(): void {
    this.isLoadingService.add();
    this.siteService.updateSite(this.site)
      .subscribe(site => {
        this.site = site;
        this.isLoadingService.remove();
        this.siteUpdated.emit(this.site);
      });
  }

  removeConfirm(): void {
    const dialogRef = this.dialog.open(RemoveSiteConfirmComponent, {
      width: '400px',
      data: { site: this.site }
    });

    dialogRef.afterClosed().subscribe((result: boolean) => {
      if (result) {
        this.siteRemoved.emit(this.site);
      }
    });
  }

}
