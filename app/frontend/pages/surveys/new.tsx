import { Head, Link, useForm } from '@inertiajs/react'
import type { SurveyFormPage } from '@/types/serializers'

type Point = Record<string, string>
type FormData = {
  survey: {
    site_name: string
    customer_name: string
    surveyed_on: string
    mode: string
    notes: string
    hazard_points: Point[]
  }
}

const input = 'mt-1 block w-full rounded border border-slate-300 px-2 py-1 text-sm'
const button = 'rounded border border-slate-300 px-3 py-1.5 text-sm hover:bg-slate-50'

export default function New({ modes, applications, sources, facts }: SurveyFormPage) {
  const emptyPoint = (): Point => {
    const point: Point = { name: '', zone: '', application: '' }
    for (const fact of facts) {
      point[fact.key] = ''
      point[`${fact.key}_source`] = ''
    }
    return point
  }

  const form = useForm<FormData>({
    survey: {
      site_name: '',
      customer_name: '',
      surveyed_on: '',
      mode: '',
      notes: '',
      hazard_points: [emptyPoint()],
    },
  })
  const { survey } = form.data
  const errors = form.errors as unknown as Record<string, string | undefined>

  const setSurvey = (field: string, value: string) => form.setData('survey', { ...survey, [field]: value })
  const setPoint = (index: number, field: string, value: string) =>
    form.setData('survey', {
      ...survey,
      hazard_points: survey.hazard_points.map((point, i) => (i === index ? { ...point, [field]: value } : point)),
    })
  const addPoint = () => form.setData('survey', { ...survey, hazard_points: [...survey.hazard_points, emptyPoint()] })
  const removePoint = (index: number) => {
    // Errors are keyed by point index, so they would land on the wrong point after a removal.
    form.clearErrors()
    form.setData('survey', { ...survey, hazard_points: survey.hazard_points.filter((_, i) => i !== index) })
  }

  const error = (key: string) =>
    errors[key] ? (
      <p role="alert" className="mt-1 text-sm text-red-700">
        {errors[key]}
      </p>
    ) : null

  return (
    <>
      <Head title="New survey" />
      <main className="mx-auto max-w-5xl px-4 py-10">
        <Link href="/surveys" className="text-sm text-slate-600 hover:underline">
          Surveys
        </Link>
        <h1 className="mt-2 text-2xl font-semibold text-slate-900">New survey</h1>

        <form
          className="mt-8 space-y-6"
          onSubmit={(event) => {
            event.preventDefault()
            form.post('/surveys')
          }}
        >
          <div className="grid gap-4 sm:grid-cols-3">
            <label className="text-sm">
              Site
              <input className={input} value={survey.site_name} onChange={(e) => setSurvey('site_name', e.target.value)} />
              {error('site_name')}
            </label>
            <label className="text-sm">
              Customer
              <input
                className={input}
                value={survey.customer_name}
                onChange={(e) => setSurvey('customer_name', e.target.value)}
              />
              {error('customer_name')}
            </label>
            <label className="text-sm">
              Date
              <input
                type="date"
                className={input}
                value={survey.surveyed_on}
                onChange={(e) => setSurvey('surveyed_on', e.target.value)}
              />
              {error('surveyed_on')}
            </label>
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <fieldset className="text-sm">
              <legend>Mode</legend>
              <div className="mt-2 flex gap-4">
                {modes.map((mode) => (
                  <label key={mode.value} className="flex items-center gap-1">
                    <input
                      type="radio"
                      name="mode"
                      value={mode.value}
                      checked={survey.mode === mode.value}
                      onChange={() => setSurvey('mode', mode.value)}
                    />
                    {mode.label}
                  </label>
                ))}
              </div>
              {error('mode')}
            </fieldset>
            <label className="text-sm">
              Notes
              <textarea className={input} rows={2} value={survey.notes} onChange={(e) => setSurvey('notes', e.target.value)} />
              {error('notes')}
            </label>
          </div>

          {error('hazard_points')}

          {survey.hazard_points.map((point, index) => (
            <section key={index} className="space-y-3 rounded-lg border border-slate-200 bg-white p-4">
              <div className="flex items-center justify-between">
                <h2 className="font-medium text-slate-900">Hazard point {index + 1}</h2>
                <button type="button" className={button} onClick={() => removePoint(index)}>
                  Remove
                </button>
              </div>
              <div className="grid gap-4 sm:grid-cols-3">
                <label className="text-sm">
                  Name
                  <input className={input} value={point.name} onChange={(e) => setPoint(index, 'name', e.target.value)} />
                  {error(`hazard_points.${index}.name`)}
                </label>
                <label className="text-sm">
                  Zone
                  <input className={input} value={point.zone} onChange={(e) => setPoint(index, 'zone', e.target.value)} />
                  {error(`hazard_points.${index}.zone`)}
                </label>
                <label className="text-sm">
                  Application
                  <select
                    className={input}
                    value={point.application}
                    onChange={(e) => setPoint(index, 'application', e.target.value)}
                  >
                    <option value=""></option>
                    {applications.map((application) => (
                      <option key={application.value} value={application.value}>
                        {application.label}
                      </option>
                    ))}
                  </select>
                  {error(`hazard_points.${index}.application`)}
                </label>
              </div>
              {facts.map((fact) => (
                <div key={fact.key} className="grid items-start gap-4 sm:grid-cols-2">
                  <label className="text-sm">
                    {fact.label} ({fact.unit})
                    <input
                      type="text"
                      inputMode="decimal"
                      className={input}
                      value={point[fact.key]}
                      onChange={(e) => setPoint(index, fact.key, e.target.value)}
                    />
                    {error(`hazard_points.${index}.${fact.key}`)}
                  </label>
                  <label className="text-sm">
                    {fact.label} source
                    <select
                      className={input}
                      value={point[`${fact.key}_source`]}
                      onChange={(e) => setPoint(index, `${fact.key}_source`, e.target.value)}
                    >
                      <option value=""></option>
                      {sources.map((source) => (
                        <option key={source.value} value={source.value}>
                          {source.label}
                        </option>
                      ))}
                    </select>
                    {error(`hazard_points.${index}.${fact.key}_source`)}
                  </label>
                </div>
              ))}
            </section>
          ))}

          <div className="flex justify-between">
            <button type="button" className={button} onClick={addPoint}>
              + Add hazard point
            </button>
            <button
              type="submit"
              disabled={form.processing}
              className="rounded bg-slate-900 px-4 py-1.5 text-sm text-white hover:bg-slate-700"
            >
              Save survey
            </button>
          </div>
        </form>
      </main>
    </>
  )
}
