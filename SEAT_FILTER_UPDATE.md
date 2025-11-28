# Seat Filtering Feature Update

## Overview
Added filter functionality to the seats management page, allowing users to filter seats by screen and seat type.

## Changes Made

### 1. **SeatsPage.tsx** - Filter UI Added
**Location:** `web/react-ts/src/pages/seats/SeatsPage.tsx`

#### New State Variables:
```tsx
const [filterScreenId, setFilterScreenId] = useState<number | undefined>();
const [filterSeatTypeId, setFilterSeatTypeId] = useState<number | undefined>();
```

#### Updated Query Key:
- Added `filterScreenId` and `filterSeatTypeId` to the query key dependency array
- Ensures data refetch when filters change

#### Updated fetchSeats Call:
```tsx
fetchSeats({
  page,
  seatRow: search || undefined,
  screenId: filterScreenId,      // NEW
  seatTypeId: filterSeatTypeId,  // NEW
})
```

#### Filter Dropdowns Added to Card Actions:
- **Screen Filter Dropdown**
  - Displays all available screens from backend
  - Resets to page 1 when changed
  - Shows "-- Tat ca phong --" (All screens) as default option

- **Seat Type Filter Dropdown**
  - Fixed seat types: VIP, Standard, Economy (IDs: 1, 2, 3)
  - Resets to page 1 when changed
  - Shows "-- Tat ca loai ghe --" (All seat types) as default option

---

### 2. **SeatForm.tsx** - Enhanced Seat Type Selection
**Location:** `web/react-ts/src/components/forms/SeatForm.tsx`

#### Changed From:
```tsx
<FormField label="Loai ghe (ID)" htmlFor="seat-type">
  <input
    id="seat-type"
    type="number"
    value={values.idSeatType ?? ''}
    onChange={(event) => handleChange('idSeatType', event.target.value)}
  />
</FormField>
```

#### Changed To:
```tsx
<FormField label="Loai ghe" htmlFor="seat-type">
  <select
    id="seat-type"
    value={values.idSeatType ?? ''}
    onChange={(event) => handleChange('idSeatType', event.target.value)}
  >
    <option value="">-- Chon loai ghe --</option>
    <option value="1">VIP</option>
    <option value="2">Standard</option>
    <option value="3">Economy</option>
  </select>
</FormField>
```

**Benefits:**
- More user-friendly dropdown instead of numeric input
- Prevents invalid seat type IDs
- Consistent with filter UI

---

### 3. **index.css** - Styling Added
**Location:** `web/react-ts/src/index.css`

#### New CSS Classes:
```css
.filter-select {
  padding: 8px 12px;
  border-radius: 8px;
  border: 1px solid #d1d5db;
  background-color: #fff;
  font: inherit;
  font-size: 14px;
  cursor: pointer;
  transition: border-color 0.2s ease, box-shadow 0.2s ease, background-color 0.2s ease;
  min-width: 150px;
}

.filter-select:hover {
  border-color: #9ca3af;
  background-color: #f9fafb;
}

.filter-select:focus {
  outline: none;
  border-color: #2563eb;
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
}

.filter-select:disabled {
  background-color: #f3f4f6;
  border-color: #e5e7eb;
  cursor: not-allowed;
  opacity: 0.6;
}
```

**Features:**
- Consistent styling with existing form elements
- Smooth transitions and hover effects
- Focus state with blue accent and shadow
- Disabled state styling
- Minimum width for better UX

---

## How It Works

### Filter Flow:
1. User selects a screen or seat type from the dropdown filters
2. State updates trigger a new query
3. Page resets to 1 (if changed)
4. `fetchSeats` API is called with the filter parameters:
   - `screenId` - Filter seats by screen
   - `seatTypeId` - Filter seats by type
5. Results are displayed in the data table

### API Integration:
The existing `fetchSeats` function in `api/seats.ts` already supports these parameters:
```typescript
export interface SeatQueryParams extends Record<string, unknown> {
  page?: number;
  limit?: number;
  screenId?: number;        // Already supported
  seatTypeId?: number;      // Already supported
  status?: string;
  seatRow?: string;
  seatNumber?: number;
}
```

---

## Seat Type Reference
```
ID | Type
---|----------
 1 | VIP
 2 | Standard
 3 | Economy
```

---

## Testing Checklist
- [ ] Filter by screen shows only seats for that screen
- [ ] Filter by seat type shows only seats of that type
- [ ] Combining both filters works correctly
- [ ] Clearing filters shows all seats
- [ ] Search still works with filters applied
- [ ] Pagination resets to page 1 when filter changes
- [ ] SeatForm dropdown works correctly when creating/editing seats
- [ ] Responsive design on mobile/tablet

---

## Future Enhancements
1. **Fetch seat types from backend** instead of hardcoding
2. **Add a "Clear All Filters" button** for quick reset
3. **Save filter preferences** to localStorage
4. **Add more filter options:**
   - Filter by status (available, maintenance, etc.)
   - Filter by seat row
5. **Display active filter count** to indicate filters are applied
6. **Add seat type management UI** to manage dynamic seat types
