<?php

namespace App\Http\Controllers;

class GiftCardController extends Controller
{

    public function __construct()
    {
        $this->middleware('auth');
    }
    public function index()
    {
        return view("gift_card.index");
    }

    public function save($id="")
    {
        return view('gift_card.save')->with('id', $id);
    }
    public function edit($id)
    {
        return view('gift_card.save')->with('id', $id);
    }

}
