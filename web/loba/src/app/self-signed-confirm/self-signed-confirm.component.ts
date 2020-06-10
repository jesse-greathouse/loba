import { Component, OnInit, Inject } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog';

import { RpcService } from '../rpc.service';

export interface DialogData {
  domain: string;
}

@Component({
  selector: 'app-self-signed-confirm',
  templateUrl: './self-signed-confirm.component.html',
  styleUrls: ['./self-signed-confirm.component.css']
})
export class SelfSignedConfirmComponent implements OnInit {

  constructor(
    private rpcService: RpcService,
    public dialogRef: MatDialogRef<SelfSignedConfirmComponent>,
    @Inject(MAT_DIALOG_DATA) public data: DialogData) {}


  ngOnInit(): void {
  }

  onNoClick(): void {
    this.dialogRef.close(false);
  }

  onOkClick(): void {
    this.rpcService.ssCert(this.data.domain)
      .subscribe(() => {
        this.dialogRef.close(true);
      });
  }

}
