import { Component, OnInit, Inject } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA} from '@angular/material/dialog';

import { User } from '../user';
import { UserService } from '../user.service';

export interface DialogData {
  user: User;
}

@Component({
  selector: 'app-remove-user-confirm',
  templateUrl: './remove-user-confirm.component.html',
  styleUrls: ['./remove-user-confirm.component.css']
})
export class RemoveUserConfirmComponent implements OnInit {


  constructor(
    private userService: UserService,
    public dialogRef: MatDialogRef<RemoveUserConfirmComponent>,
    @Inject(MAT_DIALOG_DATA) public data: DialogData) {}

  ngOnInit(): void {
  }

  onNoClick(): void {
    this.dialogRef.close(false);
  }

  onOkClick(): void {
    this.userService.deleteUser(this.data.user)
      .subscribe(() => {
        this.dialogRef.close(true);
      });
  }

}
