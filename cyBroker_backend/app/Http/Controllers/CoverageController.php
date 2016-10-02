<?php namespace App\Http\Controllers;

use App\Http\Requests;
use App\Http\Controllers\Controller;

use Illuminate\Http\Request;

class CoverageController extends Controller {

	/**
	 * Display a listing of the resource.
	 *
	 * @return Response
	 */
	public function index()
	{
		$covtitle1 = "Legal protection";
		$limit1 = '1000 €';
		$premium1 ='9 €';
		$covtitle2 = "Car replacement";
		$limit2 = '1000 €';
		$premium2 ='45 €';
		$covtitle3 = "Fire damage";
		$limit3 = '1000 €';
		$premium3 ='45 €';

		$body = 'Your contract covers:'."<br>"."<br>".$covtitle1."<br>".'Limit: '.$limit1."<br>".'Premium: '.$premium1."<br>"."<br>".$covtitle2."<br>".'Limit: '.$limit2."<br>".'Premium: '.$premium3."<br>"."<br>".$covtitle3."<br>".'Limit: '.$limit3."<br>".'Premium: '.$premium2."<br>"."<br>";
		return array(
			"title" => "Answer",
			"cov_title1" => $covtitle1,
			"cov_title2" => $covtitle2,
			"cov_title3" => $covtitle1,
			"limit1" => $limit1,
			"limit2" => $limit2,
			"limit3" => $limit3,
			"body" => $body
		);
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
