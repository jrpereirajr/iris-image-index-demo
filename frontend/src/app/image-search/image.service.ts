import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ImageService {

  constructor(private http: HttpClient) { }

  getImages(path: string): Observable<string[]> {
    return this.http.get<string[]>(`http://localhost:8092/imageserver/image-files?dir=${path}`)
  }

  getColorSimilars(image: string): Observable<any> {
    return this.http.get<any>(`http://localhost:8092/imageserver/get-color-similars?filename=${image}`);
  }

}
