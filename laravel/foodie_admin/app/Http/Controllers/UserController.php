<?php

namespace App\Http\Controllers;

use App\Mail\DynamicEmail;
use App\Models\User;
use App\Models\Role;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth');
    }


    public function index()
    {

        return view("settings.users.index");
    }


    public function edit($id)
    {
        return view('settings.users.edit')->with('id', $id);
    }

    public function adminUsers(){
        $users=User::join('role','role.id','=','users.role_id')
                    ->select('users.*','role.role_name as roleName')->where('users.id','!=',1)->get();
        return view('admin_users.index', compact(['users']));
    }

    public function createAdminUsers(){
        $roles=Role::all();
        return view('admin_users.create',compact(['roles']));

    }
    public function storeAdminUsers(Request $request){
        $name = $request->input('name');
        $password = $request->input('password');
        $email = $request->input('email');
        $role = $request->input('role');
        $validator = Validator::make($request->all(), [
                'name' => 'required|max:255',
                'email' => 'required|email',
                'password' => 'required|min:8',
                'confirm_password' => 'required|same:password',

            ]);
        if ($validator->fails()) {
            $error = $validator->errors()->first();
            return Redirect()->back()->with(['message' => $error]);
        }

        User::create([
            'name' => $name,
            'email' => $email,
            'password' => Hash::make($password),
            'role_id'=>$role,
        ]);
    
        return redirect('admin-users');

    }
    public function editAdminUsers($id){
        $user = User::join('role','role.id','=','users.role_id')->select('users.*','role.role_name as roleName')->find($id);
        $roles = Role::all();
        return view('admin_users.edit', compact(['user', 'roles']));

    }
    public function updateAdminUsers(Request $request, $id)
    {
        $name = $request->input('name');
        $password = $request->input('password');
        $old_password = $request->input('old_password');
        $email = $request->input('email');
        $role = ($id == 1) ? 1 : $request->input('role');
        if ($password == '') {
            $validator = Validator::make($request->all(), [
                'name' => 'required|max:255',
                'email' => 'required|email'
            ]);
        } else {
            $user = User::find($id);
            if (password_verify($old_password, $user->password)) {
                $validator = Validator::make($request->all(), [
                    'name' => 'required|max:255',
                    'password' => 'required|min:8',
                    'confirm_password' => 'required|same:password',
                    'email' => 'required|email'
                ]);

            } else {
                return Redirect()->back()->with(['message' => "Please enter correct old password"]);
            }

        }

        if ($validator->fails()) {
            $error = $validator->errors()->first();
            return Redirect()->back()->with(['message' => $error]);
        }

        $user = User::find($id);

        if ($user) {

            $user->name = $name;
            $user->email = $email;
            if ($password != '') {
                $user->password = Hash::make($password);
            }
            $user->role_id = $role;
            $user->save();
        }

        return redirect('admin-users');
    }
    public function deleteAdminUsers($id){
        $id = json_decode($id);

        if (is_array($id)) {

            for ($i = 0; $i < count($id); $i++) {
                $users = User::find($id[$i]);
                $users->delete();
            }

        } else {
            $user = User::find($id);
            $user->delete();
        }

        return redirect()->back();
    }


    public function profile()
    {
        $user = Auth::user();
        return view('settings.users.profile', compact(['user']));
    }

    public function update(Request $request, $id)
    {
        $name = $request->input('name');
        $password = $request->input('password');
        $old_password = $request->input('old_password');
        $email = $request->input('email');
        if ($password == '') {
            $validator = Validator::make($request->all(), [
                'name' => 'required|max:255',
                'email' => 'required|email'
            ]);
        } else {
            $user = Auth::user();
            if (password_verify($old_password, $user->password)) {
                $validator = Validator::make($request->all(), [
                    'name' => 'required|max:255',
                    'password' => 'required|min:8',
                    'confirm_password' => 'required|same:password',
                    'email' => 'required|email'
                ]);

            } else {
                return Redirect()->back()->with(['message' => "Please enter correct old password"]);
            }

        }

        if ($validator->fails()) {
            $error = $validator->errors()->first();
            return Redirect()->back()->with(['message' => $error]);
        }

        $user = User::find($id);
        if ($user) {
            $user->name = $name;
            $user->email = $email;
            if ($password != '') {
                $user->password = Hash::make($password);
            }
            $user->save();
        }

        return redirect()->back();
    }

    public function create()
    {
        return view('settings.users.create');
    }

    public function view($id)
    {
        return view('settings.users.view')->with('id', $id);
    }

}
