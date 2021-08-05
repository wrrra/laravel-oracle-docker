<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    $q = DB::connection('oracle-preprod')->select('select * from mtr_accnetstg.trn_view_appl_dealer');
    dd($q[0]);
    // return view('welcome');
});

Route::get('/sandbox','SandboxController@index');
