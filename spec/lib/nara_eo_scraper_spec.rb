require "spec_helper"


describe NaraEoScraper do

  it "strips leading/trailing whitespace from EO title" do
    html =  <<-HTML
      <hr>


      <p>
        <a name="13423"></a>
      <strong>
        <a class="pdfImage" href="http://www.gpo.gov/fdsys/pkg/FR-2007-01-26/pdf/07-374.pdf">Executive Order 13423</a></strong>
      <br>
        Strengthening Federal Environmental, Energy, and Transportation Management</p>

      <ul>

        <li>Signed: January 24, 2007</li>

        <li>Federal Register page and date: 72 FR 3919, January 26, 2007</li>

        <li>Amends: 
          <a href="/federal-register/executive-orders/2004.html#13327">EO 13327</a>, February 4, 2004</li>

        <li>Revokes: 
          <a href="/federal-register/executive-orders/1998.html#13101">EO 13101</a>, September 14, 1998; 
          <a href="/federal-register/executive-orders/1999.html#13123">EO 13123</a>, June 3, 1999; 
          <a href="/federal-register/executive-orders/1999.html#13134">EO 13134</a>, August 12, 1999; 
          <a href="/federal-register/executive-orders/2000.html#13148">EO 13148</a>, April 21, 2000; 
          <a href="/federal-register/executive-orders/2000.html#13149">EO 13149</a>, April 21, 2000</li>

        <li>See: 
          <a href="/federal-register/executive-orders/2007.html#13432">EO 13432</a>, May 14, 2007; 
          <a href="/federal-register/executive-orders/2009-obama.html#13514">EO 13514</a>, October 5, 2009</li>

        <li>Revoked by: 
          <a href="/federal-register/executive-orders/2015.html#13693">EO 13693</a>, March 25, 2015</li>


      </ul>
    HTML

    result = described_class.eo_metadata(html, 'arbitrary_president', 'arbitrary_url')
    expect(result.first.first).to eq('Strengthening Federal Environmental, Energy, and Transportation Management')
  end
   
end
