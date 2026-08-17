import { type FormEvent, useEffect, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { createQuiz, getQuiz, updateQuiz } from '../api/admin'
import { getErrorMessage } from '../api/errors'
import { handleUnauthorized } from '../auth/session'
import QuizForm from '../components/QuizForm'
import { useFlash } from '../contexts/FlashContext'
import { quizPayloadSchema } from '../schemas/quiz'
import type { QuizFormValues } from '../types/admin'

interface QuizFormPageProps {
  mode: 'create' | 'edit'
}

function createEmptyValues(): QuizFormValues {
  return {
    section: '',
    title: '',
    question: '',
    code: '',
    options: ['', ''],
    correctAnswerIndex: 0,
    explanation: '',
    source: '',
    status: 'unpublished',
    pushEnabled: false,
  }
}

function QuizFormPage({ mode }: QuizFormPageProps) {
  const [values, setValues] = useState<QuizFormValues>(createEmptyValues())
  const [pageErrorMessage, setPageErrorMessage] = useState<string | null>(null)
  const [formErrorMessage, setFormErrorMessage] = useState<string | null>(null)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const navigate = useNavigate()
  const params = useParams()
  const { showFlash } = useFlash()
  const quizId = params.id
  const missingEditId = mode === 'edit' && !quizId
  const [isLoading, setIsLoading] = useState(mode === 'edit' && Boolean(quizId))
  const [hasLoadedQuiz, setHasLoadedQuiz] = useState(mode === 'create')
  const loadErrorMessage = missingEditId
    ? '編集対象のクイズIDが見つかりません。'
    : pageErrorMessage

  useEffect(() => {
    if (mode !== 'edit') {
      return
    }

    if (!quizId) {
      return
    }

    let isCancelled = false

    const loadQuiz = async () => {
      setIsLoading(true)
      setPageErrorMessage(null)
      setHasLoadedQuiz(false)

      try {
        const quiz = await getQuiz(quizId)
        if (isCancelled) {
          return
        }

        setValues({
          section: quiz.section,
          title: quiz.title,
          question: quiz.question,
          code: quiz.code ?? '',
          options: [...quiz.options],
          correctAnswerIndex: quiz.correctAnswerIndex,
          explanation: quiz.explanation,
          source: quiz.source,
          status: quiz.status,
          pushEnabled: quiz.pushEnabled,
        })
        setHasLoadedQuiz(true)
      } catch (error) {
        if (handleUnauthorized(error, navigate)) {
          return
        }

        if (!isCancelled) {
          setPageErrorMessage(getErrorMessage(error))
        }
      } finally {
        if (!isCancelled) {
          setIsLoading(false)
        }
      }
    }

    void loadQuiz()

    return () => {
      isCancelled = true
    }
  }, [mode, navigate, quizId])

  const handleFieldChange = (
    field: 'section' | 'title' | 'question' | 'code' | 'explanation' | 'source' | 'status',
    value: string,
  ) => {
    setValues((current) => ({
      ...current,
      [field]: value,
    }))
  }

  const handleOptionChange = (index: number, value: string) => {
    setValues((current) => {
      const nextOptions = [...current.options]
      nextOptions[index] = value

      return {
        ...current,
        options: nextOptions,
      }
    })
  }

  const handleAddOption = () => {
    setValues((current) => ({
      ...current,
      options: [...current.options, ''],
    }))
  }

  const handleRemoveOption = (index: number) => {
    setValues((current) => {
      if (current.options.length <= 2) {
        return current
      }

      const nextOptions = current.options.filter((_, optionIndex) => optionIndex !== index)
      let nextCorrectAnswerIndex = current.correctAnswerIndex

      if (index < nextCorrectAnswerIndex) {
        nextCorrectAnswerIndex -= 1
      }

      if (nextCorrectAnswerIndex >= nextOptions.length) {
        nextCorrectAnswerIndex = nextOptions.length - 1
      }

      return {
        ...current,
        options: nextOptions,
        correctAnswerIndex: nextCorrectAnswerIndex,
      }
    })
  }

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setFormErrorMessage(null)

    const normalizedPayload = {
      ...values,
      section: values.section.trim(),
      title: values.title.trim(),
      question: values.question.trim(),
      code: values.code.trim(),
      options: values.options.map((option) => option.trim()),
      explanation: values.explanation.trim(),
      source: values.source.trim(),
      status: values.status,
      pushEnabled: values.pushEnabled,
    }

    const parsedPayload = quizPayloadSchema.safeParse(normalizedPayload)
    if (!parsedPayload.success) {
      setFormErrorMessage(parsedPayload.error.issues[0]?.message ?? '入力内容を確認してください')
      return
    }

    setIsSubmitting(true)

    try {
      if (mode === 'edit') {
        const quizId = params.id
        if (!quizId) {
          setFormErrorMessage('更新対象のクイズIDが見つかりません。')
          return
        }

        await updateQuiz(quizId, parsedPayload.data)
        showFlash('クイズを更新しました。')
      } else {
        await createQuiz(parsedPayload.data)
        showFlash('クイズを作成しました。')
      }

      navigate('/quizzes', { replace: true })
    } catch (error) {
      if (handleUnauthorized(error, navigate)) {
        return
      }

      setFormErrorMessage(getErrorMessage(error))
    } finally {
      setIsSubmitting(false)
    }
  }

  if (mode === 'edit' && isLoading) {
    return (
      <section className="grid min-h-[360px] place-items-center rounded-[24px] border border-[#14213d]/12 bg-white/86 p-8 text-center shadow-[0_22px_48px_rgba(20,33,61,0.12)]">
        読み込み中...
      </section>
    )
  }

  if (mode === 'edit' && !hasLoadedQuiz) {
    return (
      <section className="grid min-h-[360px] place-items-center gap-3 rounded-[24px] border border-[#14213d]/12 bg-white/86 p-8 text-center shadow-[0_22px_48px_rgba(20,33,61,0.12)]">
        <p className="m-0 text-[1.4rem] font-semibold">クイズを読み込めませんでした</p>
        <p className="m-0 text-[#4f5d75]">{loadErrorMessage ?? '対象データを取得できませんでした。'}</p>
        <Link
          className="inline-flex items-center justify-center rounded-full border border-[#14213d]/12 bg-white/90 px-4 py-3 text-sm font-medium transition duration-150 hover:-translate-y-0.5 hover:shadow-[0_12px_24px_rgba(20,33,61,0.12)]"
          to="/quizzes"
        >
          一覧へ戻る
        </Link>
      </section>
    )
  }

  return (
    <div className="grid gap-[18px]">
      {pageErrorMessage ? (
        <p className="m-0 rounded-[16px] bg-[#b42318]/10 px-4 py-3.5 text-[#7a271a]">{pageErrorMessage}</p>
      ) : null}

      <QuizForm
        description={
          mode === 'edit'
            ? '既存の問題文・選択肢・出典を更新します。保存後は一覧画面へ戻ります。'
            : '新しいクイズを管理画面から追加します。必須項目を埋めて保存してください。'
        }
        errorMessage={formErrorMessage}
        heading={mode === 'edit' ? 'クイズを編集' : 'クイズを新規作成'}
        isSubmitting={isSubmitting}
        onAddOption={handleAddOption}
        onCorrectAnswerChange={(index) =>
          setValues((current) => ({
            ...current,
            correctAnswerIndex: index,
          }))
        }
        onFieldChange={handleFieldChange}
        onPushEnabledChange={(value) =>
          setValues((current) => ({
            ...current,
            pushEnabled: value,
          }))
        }
        onOptionChange={handleOptionChange}
        onRemoveOption={handleRemoveOption}
        onSubmit={handleSubmit}
        submitLabel={mode === 'edit' ? '更新する' : '作成する'}
        values={values}
      />
    </div>
  )
}

export default QuizFormPage
