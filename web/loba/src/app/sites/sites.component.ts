import { Component, OnInit, OnChanges, Input } from '@angular/core';

import { Site } from '../site';
import { SiteService } from '../site.service';


@Component({
  selector: 'app-sites',
  templateUrl: './sites.component.html',
  styleUrls: ['./sites.component.css']
})
export class SitesComponent implements OnInit, OnChanges {

  @Input() refresh: boolean;
  selectedSite: Site;
  sites: Site[];

  constructor(
      private siteService: SiteService) { }

  ngOnInit(): void {
    this.getSites();
  }

  ngOnChanges(): void {
    this.getSites();
  }

  getSites(): void {
    this.siteService.getSites()
        .subscribe(sites => this.sites = sites);
  }

  add(domain: string): void {
    domain = domain.trim();
    if (!domain) { return; }
    this.siteService.addSite({ domain, active: true } as Site)
      .subscribe(site => {
        this.sites.push(site);
      });
  }

}
