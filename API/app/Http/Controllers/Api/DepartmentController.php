<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Department;
use Illuminate\Http\Request;

class DepartmentController extends Controller
{
    // GET /departments
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => Department::all()
        ]);
    }

    // POST /departments
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'      => 'required|string|max:100',
            'radius'    => 'required|string|max:50',   // radius wajib, disimpan meter (varchar)
            'latitude'  => 'nullable|string|max:50',
            'longitude' => 'nullable|string|max:50',
        ]);

        $department = Department::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Department created successfully.',
            'data' => $department
        ], 201);
    }

    // GET /departments/{id}
    public function show($id)
    {
        $department = Department::find($id);

        if (! $department) {
            return response()->json([
                'success' => false,
                'message' => 'Department not found.',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $department
        ]);
    }

    // PUT /departments/{id}
    public function update(Request $request, $id)
    {
        $department = Department::find($id);

        if (! $department) {
            return response()->json([
                'success' => false,
                'message' => 'Department not found.',
            ], 404);
        }

        $validated = $request->validate([
            'name'      => 'sometimes|required|string|max:100',
            'radius'    => 'sometimes|required|string|max:50',
            'latitude'  => 'nullable|string|max:50',
            'longitude' => 'nullable|string|max:50',
        ]);

        $department->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Department updated successfully.',
            'data' => $department
        ]);
    }

    // DELETE /departments/{id}
    public function destroy($id)
    {
        $department = Department::find($id);

        if (! $department) {
            return response()->json([
                'success' => false,
                'message' => 'Department not found.',
            ], 404);
        }

        $department->delete();

        return response()->json([
            'success' => true,
            'message' => 'Department deleted successfully.'
        ]);
    }
}   