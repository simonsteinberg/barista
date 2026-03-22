from barista.greet import get_version, main


def test_get_version() -> None:
    assert get_version() == "0.0.0"


def test_main_prints_expected_message(capsys) -> None:
    main()
    captured = capsys.readouterr()
    assert captured.out.strip() == "Hello barista (version 0.0.0)"
