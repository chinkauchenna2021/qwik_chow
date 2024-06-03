<?php

namespace App\Http\Controllers;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Validator;

class TaxController extends Controller
{

     public function __construct()
    {
       $this->middleware('auth');
    }


	  public function index()
    {

        return view("taxes.index");
    }


  public function edit($id)
  {
      return view('taxes.edit')->with('id',$id);
  }

   public function create()
  {
      return view('taxes.create');
  }


}
