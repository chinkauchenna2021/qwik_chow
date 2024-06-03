<?php

namespace App\Http\Controllers;

class FoodController extends Controller
{

   public function __construct()
    {
        $this->middleware('auth');
    }
	 public function index($id='')
    {
   		return view("foods.index")->with('id',$id);
    }

      public function edit($id)
    {
    	return view('foods.edit')->with('id',$id);
    }

    public function create($id='')
    {
      return view('foods.create')->with('id',$id);
    }
    public function createfood()
    {
      return view('foods.create');
    }

}
