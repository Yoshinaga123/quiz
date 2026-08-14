package main

import (
	"database/sql"
	"encoding/json"
)

func scanQuiz(scanner rowScanner) (quiz, error) {
	var item quiz
	var code sql.NullString
	var optionsJSON []byte

	err := scanner.Scan(
		&item.ID,
		&item.Section,
		&item.Title,
		&item.Question,
		&code,
		&optionsJSON,
		&item.CorrectAnswerIndex,
		&item.Explanation,
		&item.Source,
		&item.Status,
		&item.PushEnabled,
		&item.CreatedAt,
		&item.UpdatedAt,
	)
	if err != nil {
		return quiz{}, err
	}

	if code.Valid {
		item.Code = &code.String
	}

	if err := json.Unmarshal(optionsJSON, &item.Options); err != nil {
		return quiz{}, err
	}

	return item, nil
}

func scanPublicQuiz(scanner rowScanner) (publicQuiz, error) {
	var item publicQuiz
	var code sql.NullString
	var optionsJSON []byte

	if err := scanner.Scan(
		&item.ID,
		&item.Section,
		&item.Title,
		&item.Question,
		&code,
		&optionsJSON,
		&item.CorrectAnswerIndex,
		&item.Explanation,
		&item.Source,
	); err != nil {
		return publicQuiz{}, err
	}

	if code.Valid && code.String != "" {
		value := code.String
		item.Code = &value
	}

	if err := json.Unmarshal(optionsJSON, &item.Options); err != nil {
		return publicQuiz{}, err
	}

	return item, nil
}
