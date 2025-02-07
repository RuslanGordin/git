#!/bin/sh

test_description='ask merge-recursive to merge binary files'

GIT_TEST_DEFAULT_INITIAL_BRANCH_NAME=main
export GIT_TEST_DEFAULT_INITIAL_BRANCH_NAME

TEST_PASSES_SANITIZE_LEAK=true
. ./test-lib.sh

test_expect_success setup '

	cat "$TEST_DIRECTORY"/lib-diff/test-binary-1.png >m &&
	git add m &&
	git ls-files -s | sed -e "s/ 0	/ 1	/" >E1 &&
	test_tick &&
	git commit -m "initial" &&

	git branch side &&
	echo frotz >a &&
	git add a &&
	echo nitfol >>m &&
	git add a m &&
	git ls-files -s a >E0 &&
	git ls-files -s m | sed -e "s/ 0	/ 3	/" >E3 &&
	test_tick &&
	git commit -m "main adds some" &&

	git checkout side &&
	echo rezrov >>m &&
	git add m &&
	git ls-files -s m | sed -e "s/ 0	/ 2	/" >E2 &&
	test_tick &&
	git commit -m "side modifies" &&

	git tag anchor &&

	cat E0 E1 E2 E3 >expect
'

test_expect_success resolve '

	rm -f a* m* &&
	git reset --hard anchor &&

	if git merge -s resolve main
	then
		echo Oops, should not have succeeded
		false
	else
		git ls-files -s >current &&
		test_cmp expect current
	fi
'

test_expect_success recursive '

	rm -f a* m* &&
	git reset --hard anchor &&

	if git merge -s recursive main
	then
		echo Oops, should not have succeeded
		false
	else
		git ls-files -s >current &&
		test_cmp expect current
	fi
'

test_done
