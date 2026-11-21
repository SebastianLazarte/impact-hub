import { Head, Link } from '@inertiajs/react'
import type { SurveyListPage } from '@/types/serializers'

export default function Index({ surveys }: SurveyListPage) {
  return (
    <>
      <Head title="Surveys" />
      <main className="mx-auto max-w-5xl px-4 py-10">
        <h1 className="text-2xl font-semibold text-slate-900">Surveys</h1>

        {surveys.length === 0 ? (
          <p className="mt-8 text-slate-600">No surveys yet. Start one with New survey.</p>
        ) : (
          <ul className="mt-8 divide-y divide-slate-200 rounded-lg border border-slate-200 bg-white text-sm">
            {surveys.map((survey) => (
              <li key={survey.id}>
                <Link
                  href={`/surveys/${survey.id}`}
                  className="flex flex-wrap gap-x-6 gap-y-1 px-4 py-3 hover:bg-slate-50"
                >
                  <span className="font-medium text-slate-900">{survey.site_name}</span>
                  <span className="text-slate-600">{survey.customer_name}</span>
                  <span className="text-slate-600">{survey.surveyed_on}</span>
                  <span className="text-slate-600">{survey.mode === 'on_site' ? 'on site' : 'remote'}</span>
                  <span className="text-slate-600">{survey.points}</span>
                </Link>
              </li>
            ))}
          </ul>
        )}
      </main>
    </>
  )
}
