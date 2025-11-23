import apiClient from './client';

export interface UploadImageResponse {
  filename: string;
  path: string;
  url: string;
}

export const uploadImage = async (file: File): Promise<UploadImageResponse> => {
  const formData = new FormData();
  formData.append('file', file);

  const { data } = await apiClient.post<UploadImageResponse>('/upload/image', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });

  return data;
};
