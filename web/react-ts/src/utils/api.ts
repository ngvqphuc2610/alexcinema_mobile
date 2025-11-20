// utils/api.ts
export const removeEmpty = <T extends object>(payload: T): Partial<T> => {
  const result: Partial<T> = {};

  Object.entries(payload).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      (result as any)[key] = value;
    }
  });

  return result;
};
