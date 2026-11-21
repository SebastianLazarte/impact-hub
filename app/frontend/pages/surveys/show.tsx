import { Head, Link } from '@inertiajs/react'
import type { SurveyPage } from '@/types/serializers'

type Point = SurveyPage['points'][number]

const VERDICT_TEXT: Record<Point['barriers'][number]['verdict'], string> = {
  not_rated: 'not rated',
  too_weak: 'too weak',
  check_space: 'check the space',
  does_not_fit: 'does not fit',
  fits: 'fits',
}

const OUTCOME_STYLE: Record<Point['outcome']['status'], string> = {
  incomplete: 'bg-slate-100 text-slate-800',
  specified: 'bg-emerald-100 text-emerald-800',
  needs_site_check: 'bg-amber-100 text-amber-800',
  engineering_review: 'bg-rose-100 text-rose-800',
}

function PointCard({ point }: { point: Point }) {
  const { energy, outcome } = point
  return (
    <section className="rounded-lg border border-slate-200 bg-white p-4">
      <h2 className="text-lg font-medium text-slate-900">
        {point.position}. {point.name} · {point.zone} · {point.application}
      </h2>

      <p className="mt-2 text-sm text-slate-700">
        {point.facts.map((fact, index) => (
          <span key={fact.label}>
            {index > 0 && ' · '}
            {fact.label} {fact.value === null ? 'unknown' : fact.value}
            {fact.source !== null && ` (${fact.source})`}
          </span>
        ))}
      </p>

      <p className="mt-4 text-slate-900">
        Required energy{' '}
        {energy.value === null ? (
          <span>unknown{energy.reason && `: ${energy.reason}`}</span>
        ) : (
          <span className="font-medium tabular-nums">{energy.value}</span>
        )}
      </p>
      {energy.unmeasured.length > 0 && (
        <p className="text-sm text-slate-600">rests on: {energy.unmeasured.join(', ')}</p>
      )}

      <p className="mt-3 flex flex-wrap items-center gap-2 text-sm">
        <span className={`rounded px-2 py-0.5 font-medium uppercase ${OUTCOME_STYLE[outcome.status]}`}>
          {outcome.label}
        </span>
        {outcome.reason && <span className="text-slate-700">{outcome.reason}</span>}
        {point.recommendation && <span className="text-slate-700">Recommended: {point.recommendation}</span>}
        {point.other_fitting.length > 0 && (
          <span className="text-slate-700">Also fits: {point.other_fitting.join(', ')}</span>
        )}
      </p>

      {point.barriers.length > 0 && (
        <div className="mt-4 overflow-x-auto">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="text-left text-slate-600">
              <tr>
                <th className="py-2 pr-4 font-medium">Barrier</th>
                <th className="py-2 pr-4 font-medium">Rating</th>
                <th className="py-2 pr-4 font-medium">Deflection</th>
                <th className="py-2 font-medium">Verdict</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {point.barriers.map((barrier) => (
                <tr key={barrier.name}>
                  <td className="py-2 pr-4 text-slate-900">{barrier.name}</td>
                  <td className="py-2 pr-4 tabular-nums">{barrier.rating ?? 'not rated'}</td>
                  <td className="py-2 pr-4 tabular-nums">{barrier.deflection}</td>
                  <td className="py-2">
                    {VERDICT_TEXT[barrier.verdict]}
                    {barrier.reason && `: ${barrier.reason}`}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </section>
  )
}

export default function Show({ survey, catalog_notice, points }: SurveyPage) {
  return (
    <>
      <Head title={survey.site_name} />
      <main className="mx-auto max-w-5xl px-4 py-10">
        <Link href="/" className="text-sm text-slate-600 hover:underline">All surveys</Link>
        <h1 className="mt-2 text-2xl font-semibold text-slate-900">
          {survey.site_name} · {survey.customer_name} · {survey.surveyed_on} ·{' '}
          {survey.mode === 'on_site' ? 'on site' : 'remote'}
        </h1>
        <p className="mt-1 text-sm text-slate-600">{catalog_notice}</p>
        {survey.notes && <p className="mt-2 text-slate-700">{survey.notes}</p>}

        <div className="mt-8 space-y-6">
          {points.map((point) => (
            <PointCard key={point.position} point={point} />
          ))}
        </div>
      </main>
    </>
  )
}
