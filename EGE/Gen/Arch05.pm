# Copyright © 2013 Natalia D. Zemlyannikova
# Licensed under GPL version 2 or later.
# http://github.com/NZem/EGE
package EGE::Gen::Arch05;
use base 'EGE::GenBase::Sortable';

use strict;
use warnings;
use utf8;

use EGE::Random;
use EGE::Asm::Processor;
use EGE::Asm::AsmCodeGenerate;

sub sort_commands {
	my $self = shift;
	my ($reg1, $reg2, $arg, $cmd_shift, $hex_val) = $self->init_params();
	my $cmd = rnd->pick('add', 'sub', 'and', 'or', 'xor');
	$self->variants(map { $_ = "<code>$_</code>" } ("mov $reg1, $hex_val", "$cmd_shift $reg1, 4", "mov $reg2, $reg1", "$cmd $reg1, $reg2"));
	my @res_arr = ();
	my @correct_arr = ();
	cgen->{code} = [];
	cgen->add_command('mov', $reg1, $arg);
	cgen->add_command($cmd_shift, $reg1, 4);
	cgen->add_command('mov', $reg2, $reg1);
	cgen->add_command($cmd, $reg1, $reg2);
	proc->run_code(cgen->{code});
	push @res_arr, proc->get_val($reg1);
	push @correct_arr, [0,1,2,3];
	cgen->swap_commands(1,2);
	proc->run_code(cgen->{code});
	push @res_arr, proc->get_val($reg1);
	push @correct_arr, [0,2,1,3];
	cgen->swap_commands(2,3);
	proc->run_code(cgen->{code});
	push @res_arr, proc->get_val($reg1);
	push @correct_arr, [0,2,3,1];
	$self->sort_commands if (!$self->choose_correct($reg1, \@res_arr, \@correct_arr));
}

sub sort_commands_stack {
	my $self = shift;
	my ($reg1, $reg2, $arg, $cmd_shift, $hex_val) = $self->init_params();
	$self->variants(map { $_ = "<code>$_</code>" } ("mov $reg1, $hex_val", "$cmd_shift $reg1, 4", "push $reg1", "pop $reg2", "add $reg1, $reg2"));
	my @res_arr = ();
	my @correct_arr = ();
	cgen->{code} = [];
	cgen->add_command('mov', $reg1, $arg);
	cgen->add_command($cmd_shift, $reg1, 4);
	cgen->add_command('push', $reg1);
	cgen->add_command('pop', $reg2);
	cgen->add_command('add', $reg1, $reg2);
	proc->run_code(cgen->{code});
	push @res_arr, proc->get_val($reg1);
	push @correct_arr, [0,1,2,3,4];
	cgen->move_command(1,4);
	proc->run_code(cgen->{code});
	push @res_arr, proc->get_val($reg1);
	push @correct_arr, [0,2,3,4,1];
	cgen->move_command(4,3);
	proc->run_code(cgen->{code});
	# данный вариант не может являться правильным, т.к. дублируется другой последовательностью команд, но должен не дублировать предыдущие варианты
	push @res_arr, proc->get_val($reg1);
	$self->sort_commands_stack if (!$self->choose_correct($reg1, \@res_arr, \@correct_arr));
}

sub init_params {
	my $self = shift;
	my ($reg1, $reg2) = cgen->get_regs(8, 8);
	my $arg = rnd->in_range(1, 15) * 16 + rnd->in_range(1, 15);
	my $cmd_shift = rnd->pick('shl', 'shr', 'sal', 'sar', 'rol', 'ror');
	my $hex_val = sprintf '%02Xh', $arg;
	($reg1, $reg2, $arg, $cmd_shift, $hex_val);
}

sub choose_correct {
	my ($self, $reg1, $res_arr, $correct_arr) = @_;
	my @ids = ();
	for (0..$#{$correct_arr}) {
		push @ids, $_ if ($res_arr->[$_] != $res_arr->[($_+1)%3] && $res_arr->[$_] != $res_arr->[($_+2)%3]);
	}
	return '' if ($#ids == -1);
	my $id = rnd->pick(@ids);
	my $hex_val = sprintf '%02Xh', $res_arr->[$id];
	$self->{text} = <<QUESTION
Расположите команды в такой последовательности, чтобы после их выполнения в регистре $reg1 содержалось значение $hex_val:
QUESTION
;
	$self->{correct} = $correct_arr->[$id];
	$self;
}

1;
