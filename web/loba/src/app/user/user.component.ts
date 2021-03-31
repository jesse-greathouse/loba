import { Component, OnInit, OnChanges, Input, Output, EventEmitter } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';

import { User } from '../user';
import { IsLoadingService } from '../is-loading.service';
import { UserService } from '../user.service';
import { RoleService } from '../role.service';
import { RemoveUserConfirmComponent } from '../remove-user-confirm/remove-user-confirm.component'

const ADMIN = "ADMIN";
const SUPER_USER = "SUPER_USER";
const USER = "USER";

@Component({
  selector: 'app-user',
  templateUrl: './user.component.html',
  styleUrls: ['./user.component.css']
})
export class UserComponent implements OnInit, OnChanges {
  @Input() user: User;
  @Input() role: string;
  @Output() userRemoved: EventEmitter<User> = new EventEmitter();

  oldRoleId: number;
  roles: string[] = [ADMIN, SUPER_USER, USER]
  roleOffset: number = 1; // offset to start the index at 1 to mirror the roles table

  constructor(
    public dialog: MatDialog,
    private isLoadingService: IsLoadingService,
    private userService: UserService,
    private roleService: RoleService) { }

  getRoleIndex(roleName: string): number {
    return (this.roles.indexOf(roleName) + this.roleOffset);
  }

  ngOnInit(): void {
    this.resetRole();
    this.oldRoleId = this.getRoleIndex(this.role);
  }

  ngOnChanges(): void {
  }

  removeConfirm(): void {
    const dialogRef = this.dialog.open(RemoveUserConfirmComponent, {
      width: '400px',
      data: { user: this.user }
    });

    dialogRef.afterClosed().subscribe((result: boolean) => {
      if (result) {
        this.userRemoved.emit(this.user);
      }
    });
  }

  roleChange($event): void {
    let newRoleId = this.getRoleIndex($event.value);

    if (this.oldRoleId !== newRoleId) {
      // Attempt to remove the old role
      this.roleService.removeRole(this.user, {
        id: this.oldRoleId,
        name: this.roles[this.oldRoleId]
      })
      .subscribe(_ => {
        // Assign the new role
        this.roleService.assignRole(this.user, {
          id: newRoleId,
          name: this.roles[newRoleId]
        })
        .subscribe(_ => {
          this.oldRoleId = newRoleId;
          this.isLoadingService.remove();
        });
      });
    }
  }

  focusOut(): void {
    this.save();
  }

  save(): void {
    this.isLoadingService.add();
    this.user.roles = [this.role]
    this.userService.updateUser(this.user)
      .subscribe(user => {
        this.user = user;
        this.resetRole();
        this.isLoadingService.remove();
      });
  }

  resetRole(): void {
    if (this.user.roles.length > 0) {
      if (this.user.roles.indexOf(ADMIN) !== -1) {
        this.role = this.roles[0];
      }

      if (this.user.roles.indexOf(SUPER_USER) !== -1) {
        this.role = this.roles[1];
      }

      if (this.user.roles.indexOf(USER) !== -1) {
        this.role = this.roles[2];
      }
    }
  }

}
