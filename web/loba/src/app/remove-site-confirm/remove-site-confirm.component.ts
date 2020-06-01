import { Component, OnInit, Inject } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog';

import { Site } from '../site';
import { SiteService } from '../site.service';

export interface DialogData {
  site: Site;
}

@Component({
  selector: 'app-remove-site-confirm',
  templateUrl: './remove-site-confirm.component.html',
  styleUrls: ['./remove-site-confirm.component.css']
})
export class RemoveSiteConfirmComponent implements OnInit {

  constructor(
    private siteService: SiteService,
    public dialogRef: MatDialogRef<RemoveSiteConfirmComponent>,
    @Inject(MAT_DIALOG_DATA) public data: DialogData) {}

  ngOnInit(): void {
  }

  onNoClick(): void {
    this.dialogRef.close(false);
  }

  onOkClick(): void {
    this.siteService.deleteSite(this.data.site)
      .subscribe(() => {
        this.dialogRef.close(true);
      });
  }

}
