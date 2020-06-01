import { Component, OnInit, Inject } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog';

import { Server } from '../server';
import { ServerService } from '../server.service';

export interface DialogData {
  server: Server;
}

@Component({
  selector: 'app-remove-server-confirm',
  templateUrl: './remove-server-confirm.component.html',
  styleUrls: ['./remove-server-confirm.component.css']
})
export class RemoveServerConfirmComponent implements OnInit {

  constructor(
    private serverService: ServerService,
    public dialogRef: MatDialogRef<RemoveServerConfirmComponent>,
    @Inject(MAT_DIALOG_DATA) public data: DialogData) {}

  ngOnInit(): void {
  }

  onNoClick(): void {
    this.dialogRef.close(false);
  }

  onOkClick(): void {
    this.serverService.deleteServer(this.data.server)
      .subscribe(() => {
        this.dialogRef.close(true);
      });
  }

}
