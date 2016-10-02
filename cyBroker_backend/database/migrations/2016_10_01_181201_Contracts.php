<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class Contracts extends Migration {

	/**
	 * Run the migrations.
	 *
	 * @return void
	 */
	public function up()
	{
		Schema::create('Contracts', function(Blueprint $table)
		{
			$table->increments('id');
			$table->string('sum');
			$table->string('contr_start');
			$table->string('contr_end');
			$table->string('veh_id');

		});
	}

	/**
	 * Reverse the migrations.
	 *
	 * @return void
	 */
	public function down()
	{
		Schema::drop('Contracts');
	}

}
