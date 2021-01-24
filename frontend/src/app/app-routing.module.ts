import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { TranslateModule } from '@ngx-translate/core';
import { AuthGuard } from './auth/auth.guard';


const routes: Routes = [
  {
    path: '',
    redirectTo: 'image-search',
    pathMatch: 'full'
  },
  {
    path: 'auth',
    loadChildren: () => import('./auth/auth.module').then(m => m.AuthModule)
  },
  {
    path: 'notebook',
    loadChildren: () => import('./notebook/notebook.module').then(m => m.NotebookModule),
    canActivate: [AuthGuard]
  },
  {
    path: 'image-search',
    loadChildren: () => import('./image-search/image-search.module').then(m => m.ImageSearchModule),
    canActivate: [AuthGuard]
  },
  {
    path: '**',
    redirectTo: '/'
  }
];

@NgModule({
  imports: [RouterModule.forRoot(routes), TranslateModule],
  exports: [RouterModule, TranslateModule]
})
export class AppRoutingModule { }
