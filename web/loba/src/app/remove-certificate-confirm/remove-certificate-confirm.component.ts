import { Component, OnInit, Inject } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog';

import { Certificate } from '../certificate';
import { CertificateService } from '../certificate.service';

export interface DialogData {
  certificate: Certificate;
}

@Component({
  selector: 'app-remove-certificate-confirm',
  templateUrl: './remove-certificate-confirm.component.html',
  styleUrls: ['./remove-certificate-confirm.component.css']
})
export class RemoveCertificateConfirmComponent implements OnInit {

  constructor(
    private certificateService: CertificateService,
    public dialogRef: MatDialogRef<RemoveCertificateConfirmComponent>,
    @Inject(MAT_DIALOG_DATA) public data: DialogData) {}

  ngOnInit(): void {
  }

  onNoClick(): void {
    this.dialogRef.close(false);
  }

  onOkClick(): void {
    this.certificateService.removeCertificate(this.data.certificate)
      .subscribe(() => {
        this.dialogRef.close(true);
      });
  }

}
