<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Employee;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class AuthController extends Controller
{
    // ===========================================
    // LOGIN (JWT AUTH)
    // ===========================================
    public function login(Request $request)
    {
        // 1. Validasi input
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Input tidak valid',
                'errors'  => $validator->errors()
            ], 422);
        }

        // 2. Ambil kredensial
        $credentials = $request->only('email', 'password');

        try {
            // 3. Attempt login pakai JWTAuth
            if (!$token = JWTAuth::attempt($credentials)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Email atau Password salah'
                ], 401);
            }
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat token'
            ], 500);
        }

        // 4. User login
        $user = Auth::user();

        // 5. Cek relasi employee
        $employee = Employee::where('user_id', $user->id)->first();

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'token'   => $token,
            'user'    => [
                'id'        => $user->id,
                'email'     => $user->email,
                'role'      => $user->is_admin,
                'employee'  => $employee ? [
                    'id'          => $employee->id,
                    'first_name'  => $employee->first_name,
                    'last_name'   => $employee->last_name,
                    'phone'       => $employee->phone,
                    'address'     => $employee->address,
                ] : null
            ]
        ]);
    }

    // ===========================================
    // RESET PASSWORD
    // ===========================================
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email'                 => 'required|email|exists:users,email',
            'password'              => 'required|min:6|confirmed'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors'  => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak ditemukan'
            ], 404);
        }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diubah'
        ], 200);
    }

    // ===========================================
    // LOGOUT (JWT)
    // ===========================================
    public function logout(Request $request)
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());

            return response()->json([
                'success' => true,
                'message' => 'Logout berhasil'
            ], 200);

        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal logout'
            ], 500);
        }
    }
}
