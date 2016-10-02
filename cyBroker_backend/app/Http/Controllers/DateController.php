<?php namespace App\Http\Controllers;

use App\Http\Requests;
use App\Http\Controllers\Controller;

use Illuminate\Http\Request;

class DateController extends Controller {

	/**
	 * Display a listing of the resource.
	 *
	 * @return Response
	 */
	public function index()
	{

		//Raw data Like a boss :)
		$d_start = date_create_from_format ('j-M-Y', '15-Feb-2016')->format('d-m-Y');
		$d_end = date_create_from_format ('j-M-Y', '15-Jul-2016')->format('d-m-Y');
		$t_start = date_create_from_format ('H\h i\m s\s','09h 10m 03s')->format('H:i:s');
		$t_end = date_create_from_format ('H\h i\m s\s','23h 18m 05s')->format('H:i:s');


		$body_start = "Your contract starts at  $d_start  $t_start";
		$body_end = "Your contract ends at  $d_end  $t_end";


		$info = array(
			"title" => "Answer",
			"date_start" => $d_start,
			"date_end" => $d_end,
			"time_start" => $t_start,
			"time_end" => $t_end,
			"body_start" => $body_start,
			"body_end" =>  $body_end
		);

		//
		return $info;

	}

	/**
	 * Show the form for creating a new resource.
	 *
	 * @return Response
	 */
	public function create()
	{
		//
	}

	/**
	 * Store a newly created resource in storage.
	 *
	 * @return Response
	 */
	public function store()
	{
		//
	}

	/**
	 * Display the specified resource.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function show($id)
	{
		//
	}

	/**
	 * Show the form for editing the specified resource.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function edit($id)
	{
		//
	}

	/**
	 * Update the specified resource in storage.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function update($id)
	{
		//
	}

	/**
	 * Remove the specified resource from storage.
	 *
	 * @param  int  $id
	 * @return Response
	 */
	public function destroy($id)
	{
		//
	}

}
