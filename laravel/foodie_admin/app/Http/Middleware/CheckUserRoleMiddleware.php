<?php

namespace App\Http\Middleware;

use App\Models\User;
use Auth;
use Closure;

class CheckUserRoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Closure $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {

        if (auth()->check()) {
            $user = auth()->user();

            $users = User::join('role', 'role.id', '=', 'users.role_id')->where('users.id', '=', $user->id)->select('role.role_name as roleName')->first();

            session(['user_role' => $users->roleName]);

        }
        return $next($request);
    }
}